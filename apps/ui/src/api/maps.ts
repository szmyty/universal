import api from "@/lib/api";
import { KeplerGlSchema } from "@kepler.gl/schemas";
import type { MapState, OIDCUser } from "@/types";
import { v4 as uuidv4 } from "uuid";

// Payload structure sent to backend
export type SaveMapPayload = {
    id?: number | string;
    name: string;
    description?: string;
    config: unknown; // Kepler schema output
    updated_at?: string;
    created_at?: string;
};

// Save (create or update) a map to the backend
export async function saveMap({
    mapId,
    mapState,
    user,
}: {
    mapId?: number | string;
    mapState: any; // full Kepler state (usually from store)
    user: OIDCUser;
}) {
    const config = KeplerGlSchema.save(mapState);

    const payload: SaveMapPayload = {
        id: mapId ?? uuidv4(),
        name: config.config.label ?? "Untitled Map",
        description: "", // update if you support it
        config,
        updated_at: new Date().toISOString(),
    };

    return api.post(`/maps/${payload.id}`, {
        ...payload,
        user_id: user.sub, // backend should check this
    });
}

// Fetch a single map by ID
export async function fetchMap(id: string | number): Promise<MapState> {
    const res = await api.get<MapState>(`/maps/${id}`);
    return res.data;
}

// List all maps for the current user
export async function listMaps(): Promise<MapState[]> {
    const res = await api.get<MapState[]>("/maps");
    return res.data;
}

// Delete a map by ID
export async function deleteMap(id: string | number): Promise<void> {
    await api.delete(`/maps/${id}`);
}
