import React, { useEffect, useState } from "react";
import axios from "axios";
import { config } from "@universal/config";
import type { MapState, MapStateCreate } from "@universal/models";
import { Button } from "@universal/components";
import { saveMap } from "@universal/api/maps";

export default function MapStateManager() {
    const [mapStates, setMapStates] = useState<MapState[]>([]);
    const [selectedId, setSelectedId] = useState<number | null>(null);
    const [form, setForm] = useState<MapStateCreate>({
        name: "",
        description: "",
        state: "",
    });

    const fetchStates = async () => {
        try {
            const res = await axios.get<MapState[]>(
                `${config.api.baseUrl}/maps`,
            );
            setMapStates(res.data);
            if (res.data.length && selectedId === null) {
                setSelectedId(res.data[0].id);
            }
        } catch (err) {
            console.error("Failed to fetch map states", err);
        }
    };

    useEffect(() => {
        fetchStates();
    }, []);

    const handleChange = (
        e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>,
    ) => {
        const { name, value } = e.target;
        setForm((prev) => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            const res = await axios.post<MapState>(
                `${config.api.baseUrl}/maps`,
                form,
            );
            setForm({ name: "", description: "", state: "" });
            await fetchStates();
            setSelectedId(res.data.id);
        } catch (err) {
            console.error("Failed to create map state", err);
        }
    };

    const selected = mapStates.find((m) => m.id === selectedId);

    const handleSaveMap = async (mapName: string) => {
        const mapToSave = KeplerGlSchema.save(map);
        dispatch(setSaveMapStatus("ongoing"));
        try {
            const mapNameUrl = mapName.toLowerCase().replace(/\s+/g, "_");
            await localforage.setItem(mapNameUrl, {
                name: mapName,
                description: `Description for ${mapName}`,
                state: mapToSave,
            });

            const exportedMapList = await localforage.getItem<string[] | null>(
                "exportedMaps",
            );
            if (exportedMapList) {
                await localforage.setItem("exportedMaps", [
                    ...exportedMapList,
                    mapNameUrl,
                ]);
            } else {
                await localforage.setItem("exportedMaps", [mapNameUrl]);
            }
            setMapName("");
            dispatch(setSaveMapStatus("success"));
            dispatch(showModalUploadMap(false));
            // dispath to that url (i will do that)
        } catch (error) {
            console.error("Failed to save map:", error);
            dispatchEvent(setSaveMapStatus("error"));
            if (error instanceof Error) {
                dispatchEvent(saveMapError(error.message));
            } else {
                dispatchEvent(saveMapError("An unknown error occurred"));
            }
        }
    };

    const pathname = window.location.pathname;

    return (
        <div className="space-y-4">
            <div>
                <label className="block font-semibold mb-1">
                    Select Map State
                </label>
                <select
                    className="border p-2 rounded w-full"
                    value={selectedId ?? ""}
                    onChange={(e) => setSelectedId(Number(e.target.value))}
                >
                    <option value="">-- Select --</option>
                    {mapStates.map((ms) => (
                        <option key={ms.id} value={ms.id}>
                            {ms.name}
                        </option>
                    ))}
                </select>
            </div>

            {selected && (
                <div className="border rounded p-4 bg-gray-50 space-y-2">
                    <h3 className="font-semibold text-lg">{selected.name}</h3>
                    <p className="text-sm text-gray-600">
                        {selected.description}
                    </p>
                    <pre className="bg-white p-2 rounded overflow-auto text-xs">
                        {selected.state}
                    </pre>
                </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-2">
                <h3 className="font-semibold">Create New Map State</h3>
                <input
                    className="border p-2 rounded w-full"
                    type="text"
                    name="name"
                    placeholder="Name"
                    value={form.name}
                    onChange={handleChange}
                    required
                />
                <input
                    className="border p-2 rounded w-full"
                    type="text"
                    name="description"
                    placeholder="Description"
                    value={form.description}
                    onChange={handleChange}
                    required
                />
                <textarea
                    className="border p-2 rounded w-full font-mono"
                    name="state"
                    placeholder="JSON state"
                    rows={4}
                    value={form.state}
                    onChange={handleChange}
                    required
                />
                <Button type="submit">Create</Button>
            </form>
        </div>
    );
}
