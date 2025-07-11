import type { QueryClient, UseMutationResult } from "@tanstack/react-query";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
    createMap,
    fetchAllMaps,
    fetchMapById,
    saveMap,
} from "@universal/api/maps";
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

import { useQuery } from "@tanstack/react-query";
import { fetchMyMaps } from "@universal/api/maps";

export const useMaps = () => {
    return useQuery<MapRead[]>({
        queryKey: ["maps", "me"],
        queryFn: fetchAllMaps,
    });
};

// ✅ NEW: Get single map by ID
export const useMapById = (id?: string) => {
    return useQuery<MapRead>({
        queryKey: ["map", id],
        queryFn: () => {
            if (!id) throw new Error("Map ID is required");
            return fetchMapById(id);
        },
        enabled: !!id, // only run when `id` is defined
    });
};
