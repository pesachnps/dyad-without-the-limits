import log from "electron-log";
import { createLoggedHandler } from "./safe_handle";
import {
  appendSnippets,
  readMeta,
  retrieveContext,
  updateRollingSummary,
  rebuildIndex,
  type SmartContextSnippet,
  type SmartContextMeta,
} from "../utils/smart_context_store";

const logger = log.scope("smart_context_handlers");
const handle = createLoggedHandler(logger);

export interface UpsertSnippetsParams {
  chatId: number;
  snippets: Array<{
    text: string;
    source:
      | { type: "message"; messageIndex?: number }
      | { type: "code"; filePath: string }
      | { type: "attachment"; name: string; mime?: string }
      | { type: "other"; label?: string };
  }>;
}

export interface RetrieveContextParams {
  chatId: number;
  query: string;
  budgetTokens: number;
}

export function registerSmartContextHandlers() {
  handle("sc:get-meta", async (_event, chatId: number): Promise<SmartContextMeta> => {
    return readMeta(chatId);
  });

  handle(
    "sc:upsert-snippets",
    async (_event, params: UpsertSnippetsParams): Promise<number> => {
      const count = await appendSnippets(params.chatId, params.snippets);
      return count;
    },
  );

  handle(
    "sc:update-rolling-summary",
    async (_event, params: { chatId: number; summary: string }): Promise<SmartContextMeta> => {
      return updateRollingSummary(params.chatId, params.summary);
    },
  );

  handle(
    "sc:retrieve-context",
    async (_event, params: RetrieveContextParams) => {
      return retrieveContext(params.chatId, params.query, params.budgetTokens);
    },
  );

  handle("sc:rebuild-index", async (_event, chatId: number) => {
    await rebuildIndex(chatId);
    return { ok: true } as const;
  });
}

