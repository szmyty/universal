// types/maps.ts

import type { OIDCUser } from "@universal/models";

export type MapBase = {
    name: string;
    description: string;
    state: string; // JSON string (e.g. Kepler map config)
};

export type MapCreate = MapBase;

export type MapUpdate = MapBase;

export type MapSave = {
    id?: number; // optional: triggers update
} & MapBase;

export type MapRead = MapBase & {
    id: number;
    user_id: string;
    user: OIDCUser;
    created_at: string; // ISO datetime string
    updated_at: string;
};
