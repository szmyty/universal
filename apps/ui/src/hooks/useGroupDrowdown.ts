import { useEffect, useMemo, useState } from "react";
import { useMaps } from "@/hooks/useMaps"; // <-- replace with your actual hook
import { useMapRouteInfo } from "@/hooks/useMapRouteInfo";

type Option = { value: string; name: string };

export function useGroupDropdown() {
    const { pathname, category, id } = useMapRouteInfo();
    const [group, setGroup] = useState<string>("");
    const { data: maps, isLoading } = useMaps(); // queryKey: ["maps", "me"]

    const groupOptions: Option[] = useMemo(() => {
        if (!maps) return [];

        return maps.map((m) => ({
            value: String(m.id), // assuming m.id is a number
            name: m.name,
        }));
    }, [maps]);

    useEffect(() => {
        if (category === "group" && id && groupOptions.length > 0) {
            const match = groupOptions.find((go) => go.value === id);
            if (match) {
                setGroup(id);
            }
        }
    }, [groupOptions, category, id]);

    return {
        group,
        setGroup,
        groupOptions,
        isLoading,
    };
}

const { group, setGroup, groupOptions, isLoading } = useGroupDropdown();
