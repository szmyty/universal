import { get, post, put, del } from "@universal/utils/request";
import type { MapRead, MapCreate, MapUpdate } from "@universal/models/maps";

/**
 * Fetch maps owned by the current user.
 */
export const fetchMyMaps = () => get<MapRead[]>("/maps/me");

/**
 * Fetch all maps (admin only).
 */
export const fetchAllMaps = () => get<MapRead[]>("/maps");

/**
 * Fetch a specific map by ID (requires owner or admin).
 */
export const fetchMapById = (id: number) => get<MapRead>(`/maps/${id}`);

/**
 * Create a new map associated with the current user.
 */
export const createMap = (payload: MapCreate) =>
    post<MapRead>("/maps", payload);

/**
 * Update a map you own (or as admin).
 */
export const updateMap = (id: number, payload: MapUpdate) =>
    put<MapRead>(`/maps/${id}`, payload);

/**
 * Delete a map you own (or as admin).
 */
export const deleteMap = (id: number) => del<MapRead>(`/maps/${id}`);
