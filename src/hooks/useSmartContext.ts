import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { IpcClient } from "@/ipc/ipc_client";
import type {
  SmartContextMeta,
  SmartContextSnippet,
  SmartContextRetrieveResult,
} from "@/ipc/ipc_types";

export function useSmartContextMeta(chatId: number) {
  return useQuery<SmartContextMeta, Error>({
    queryKey: ["smart-context", chatId, "meta"],
    queryFn: async () => {
      const ipc = IpcClient.getInstance();
      return ipc.getSmartContextMeta(chatId);
    },
    enabled: !!chatId,
  });
}

export function useRetrieveSmartContext(
  chatId: number,
  query: string,
  budgetTokens: number,
) {
  return useQuery<SmartContextRetrieveResult, Error>({
    queryKey: ["smart-context", chatId, "retrieve", query, budgetTokens],
    queryFn: async () => {
      const ipc = IpcClient.getInstance();
      return ipc.retrieveSmartContext({ chatId, query, budgetTokens });
    },
    enabled: !!chatId && !!query && budgetTokens > 0,
    meta: { showErrorToast: true },
  });
}

export function useUpsertSmartContextSnippets(chatId: number) {
  const qc = useQueryClient();
  return useMutation<number, Error, Array<Pick<SmartContextSnippet, "text" | "source">>>({
    mutationFn: async (snippets) => {
      const ipc = IpcClient.getInstance();
      return ipc.upsertSmartContextSnippets(chatId, snippets);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["smart-context", chatId] });
    },
  });
}

export function useUpdateRollingSummary(chatId: number) {
  const qc = useQueryClient();
  return useMutation<SmartContextMeta, Error, { summary: string }>({
    mutationFn: async ({ summary }) => {
      const ipc = IpcClient.getInstance();
      return ipc.updateSmartContextRollingSummary(chatId, summary);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["smart-context", chatId, "meta"] });
    },
  });
}

