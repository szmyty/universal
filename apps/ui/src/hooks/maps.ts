import type { QueryClient, UseMutationResult } from "@tanstack/react-query";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createMap, saveMap } from "@universal/api/maps";
import type {
    MapCreate,
    MapBase,
    MapRead,
    MapSave,
} from "@universal/models/maps";

export const useCreateMapMutation = (): UseMutationResult<
    MapRead,
    Error,
    MapBase,
    unknown
> => {
    const queryClient: QueryClient = useQueryClient();

    return useMutation({
        mutationFn: (payload: MapCreate) => createMap(payload),
        onSuccess: (newMap: MapRead) => {
            console.log("✅ Created map:", newMap);

            // Optional: Invalidate cached maps to refresh list after save
            queryClient.invalidateQueries({ queryKey: ["maps", "me"] });
        },
        onError: (error) => {
            console.error("❌ Failed to create map", error);
        },
    });
};

export const useSaveMapMutation = (): UseMutationResult<
    MapRead,
    Error,
    MapSave,
    unknown
> => {
    const queryClient: QueryClient = useQueryClient();

    return useMutation({
        mutationFn: (payload: MapSave) => saveMap(payload),
        onSuccess: (saved: MapRead) => {
            console.log("✅ Map saved (create or update):", saved);

            queryClient.invalidateQueries({ queryKey: ["maps", "me"] });

            // Optionally: set active map in state, flash UI success, etc.
        },
        onError: (error) => {
            console.error("❌ Failed to save map:", error);
        },
    });
};
