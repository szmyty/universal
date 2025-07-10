import { get, post, put, del } from "@universal/utils/request";
import type {
    MapRead,
    MapCreate,
    MapSave,
    MapUpdate,
} from "@universal/models/maps";

/**
 * Fetch maps owned by the current user.
 */
export const fetchMyMaps = (): Promise<MapRead[]> => get<MapRead[]>("/maps/me");

/**
 * Fetch all maps (admin only).
 */
export const fetchAllMaps = (): Promise<MapRead[]> => get<MapRead[]>("/maps");

/**
 * Fetch a specific map by ID (requires owner or admin).
 */
export const fetchMapById = (id: number): Promise<MapRead> =>
    get<MapRead>(`/maps/${id}`);

/**
 * Create a new map associated with the current user.
 */
export const createMap = (payload: MapCreate): Promise<MapRead> =>
    post<MapRead>("/maps", payload);

/**
 * Save a map (create or update).
 */
export const saveMap = (payload: MapSave): Promise<MapRead> =>
    post<MapRead>("/maps", payload);

/**
 * Update a map you own (or as admin).
 */
export const updateMap = (id: number, payload: MapUpdate): Promise<MapRead> =>
    put<MapRead>(`/maps/${id}`, payload);

/**
 * Delete a map you own (or as admin).
 */
export const deleteMap = (id: number): Promise<MapRead> =>
    del<MapRead>(`/maps/${id}`);
