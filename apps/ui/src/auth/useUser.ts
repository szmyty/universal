import { useEffect, useState } from "react";
import axios from "axios";
import { config } from "@universal/config";
import type { UserProfile } from "@universal/models";

// You can export this if needed elsewhere
export interface UseUserResult {
    user: UserProfile | null;
    isLoading: boolean;
    error: Error | null;
}

export function useUser(): UseUserResult {
    const [user, setUser] = useState<UserProfile | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<Error | null>(null);

    const url = `${config.api.user}`;

    useEffect(() => {
        const fetchUser = async () => {
            try {
                const res = await axios.get<UserProfile>(url, {
                    withCredentials: true, // send cookies if needed
                });
                setUser(res.data);
            } catch (err) {
                setError(err as Error);
                setUser(null);
            } finally {
                setIsLoading(false);
            }
        };

        fetchUser();
    }, [url]);

    return { user, isLoading, error };
}
