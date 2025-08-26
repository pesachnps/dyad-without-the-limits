import path from "node:path";
import { promises as fs } from "node:fs";
import { randomUUID } from "node:crypto";
import { getUserDataPath } from "../../paths/paths";
import { estimateTokens } from "./token_utils";

export type SmartContextSource =
  | { type: "message"; messageIndex?: number }
  | { type: "code"; filePath: string }
  | { type: "attachment"; name: string; mime?: string }
  | { type: "other"; label?: string };

export interface SmartContextSnippet {
  id: string;
  text: string;
  score?: number;
  source: SmartContextSource;
  ts: number; // epoch ms
  tokens?: number;
}

export interface SmartContextMetaConfig {
  maxSnippets?: number;
}

export interface SmartContextMeta {
  entityId: string; // e.g., chatId as string
  updatedAt: number;
  rollingSummary?: string;
  summaryTokens?: number;
  config?: SmartContextMetaConfig;
}

function getThreadDir(chatId: number): string {
  const base = path.join(getUserDataPath(), "smart-context", "threads");
  return path.join(base, String(chatId));
}

function getMetaPath(chatId: number): string {
  return path.join(getThreadDir(chatId), "meta.json");
}

function getSnippetsPath(chatId: number): string {
  return path.join(getThreadDir(chatId), "snippets.jsonl");
}

async function ensureDir(dir: string): Promise<void> {
  await fs.mkdir(dir, { recursive: true });
}

export async function readMeta(chatId: number): Promise<SmartContextMeta> {
  const dir = getThreadDir(chatId);
  await ensureDir(dir);
  const metaPath = getMetaPath(chatId);
  try {
    const raw = await fs.readFile(metaPath, "utf8");
    const meta = JSON.parse(raw) as SmartContextMeta;
    return meta;
  } catch {
    const fresh: SmartContextMeta = {
      entityId: String(chatId),
      updatedAt: Date.now(),
      rollingSummary: "",
      summaryTokens: 0,
      config: { maxSnippets: 400 },
    };
    await fs.writeFile(metaPath, JSON.stringify(fresh, null, 2), "utf8");
    return fresh;
  }
}

export async function writeMeta(
  chatId: number,
  meta: SmartContextMeta,
): Promise<void> {
  const dir = getThreadDir(chatId);
  await ensureDir(dir);
  const metaPath = getMetaPath(chatId);
  const updated: SmartContextMeta = {
    ...meta,
    entityId: String(chatId),
    updatedAt: Date.now(),
  };
  await fs.writeFile(metaPath, JSON.stringify(updated, null, 2), "utf8");
}

export async function updateRollingSummary(
  chatId: number,
  summary: string,
): Promise<SmartContextMeta> {
  const meta = await readMeta(chatId);
  const summaryTokens = estimateTokens(summary || "");
  const next: SmartContextMeta = {
    ...meta,
    rollingSummary: summary,
    summaryTokens,
  };
  await writeMeta(chatId, next);
  return next;
}

export async function appendSnippets(
  chatId: number,
  snippets: Omit<SmartContextSnippet, "id" | "ts" | "tokens">[],
): Promise<number> {
  const dir = getThreadDir(chatId);
  await ensureDir(dir);
  const snippetsPath = getSnippetsPath(chatId);
  const withDefaults: SmartContextSnippet[] = snippets.map((s) => ({
    id: randomUUID(),
    ts: Date.now(),
    tokens: estimateTokens(s.text),
    ...s,
  }));
  const lines = withDefaults.map((obj) => JSON.stringify(obj)).join("\n");
  await fs.appendFile(snippetsPath, (lines ? lines + "\n" : ""), "utf8");

  // prune if exceeded max
  const meta = await readMeta(chatId);
  const maxSnippets = meta.config?.maxSnippets ?? 400;
  try {
    const file = await fs.readFile(snippetsPath, "utf8");
    const allLines = file.split("\n").filter(Boolean);
    if (allLines.length > maxSnippets) {
      const toKeep = allLines.slice(allLines.length - maxSnippets);
      await fs.writeFile(snippetsPath, toKeep.join("\n") + "\n", "utf8");
      return toKeep.length;
    }
    return allLines.length;
  } catch {
    return withDefaults.length;
  }
}

export async function readAllSnippets(chatId: number): Promise<SmartContextSnippet[]> {
  try {
    const raw = await fs.readFile(getSnippetsPath(chatId), "utf8");
    return raw
      .split("\n")
      .filter(Boolean)
      .map((line) => JSON.parse(line) as SmartContextSnippet);
  } catch {
    return [];
  }
}

function normalize(value: number, min: number, max: number): number {
  if (max === min) return 0;
  return (value - min) / (max - min);
}

function keywordScore(text: string, query: string): number {
  const toTokens = (s: string) =>
    s
      .toLowerCase()
      .replace(/[^a-z0-9_\- ]+/g, " ")
      .split(/\s+/)
      .filter(Boolean);
  const qTokens = new Set(toTokens(query));
  const tTokens = toTokens(text);
  if (qTokens.size === 0 || tTokens.length === 0) return 0;
  let hits = 0;
  for (const tok of tTokens) if (qTokens.has(tok)) hits++;
  return hits / tTokens.length; // simple overlap ratio
}

export interface RetrieveContextResult {
  rollingSummary?: string;
  usedTokens: number;
  snippets: SmartContextSnippet[];
}

export async function retrieveContext(
  chatId: number,
  query: string,
  budgetTokens: number,
): Promise<RetrieveContextResult> {
  const meta = await readMeta(chatId);
  const snippets = await readAllSnippets(chatId);
  const now = Date.now();
  let minTs = now;
  let maxTs = 0;
  for (const s of snippets) {
    if (s.ts < minTs) minTs = s.ts;
    if (s.ts > maxTs) maxTs = s.ts;
  }
  const scored = snippets.map((s) => {
    const recency = normalize(s.ts, minTs, maxTs);
    const kw = keywordScore(s.text, query);
    const base = 0.6 * kw + 0.4 * recency;
    const score = base;
    return { ...s, score } as SmartContextSnippet;
  });
  scored.sort((a, b) => (b.score ?? 0) - (a.score ?? 0));

  const picked: SmartContextSnippet[] = [];
  let usedTokens = 0;
  for (const s of scored) {
    const t = s.tokens ?? estimateTokens(s.text);
    if (usedTokens + t > budgetTokens) break;
    picked.push(s);
    usedTokens += t;
  }

  const rollingSummary = meta.rollingSummary || "";
  return { rollingSummary, usedTokens, snippets: picked };
}

export async function rebuildIndex(_chatId: number): Promise<void> {
  // Placeholder for future embedding/vector index rebuild.
  return;
}

