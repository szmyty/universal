import { useMutation, useQueryClient } from "@tanstack/react-query";
import { createMap } from "@universal/api/maps";
import type { MapCreate, MapRead } from "@universal/models/maps";

export const useCreateMapMutation = () => {
    const queryClient = useQueryClient();

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
