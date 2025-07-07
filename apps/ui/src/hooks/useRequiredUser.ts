import { useOIDCUser } from "./useUser";
import { useEffect } from "react";
import { useNavigate } from "@tanstack/react-router";

/**
 * Waits for OIDC user data to be available.
 * If user is not authenticated, can optionally redirect or throw.
 */
export function useRequireUser({
    redirectTo,
    throwIfMissing = false,
}: {
    redirectTo?: string;
    throwIfMissing?: boolean;
} = {}) {
    const { data: user, isLoading, error } = useOIDCUser();
    const navigate = useNavigate();

    useEffect(() => {
        if (!isLoading && !user && redirectTo) {
            navigate({ to: redirectTo });
        }

        if (!isLoading && !user && throwIfMissing) {
            throw new Error("User not authenticated");
        }
    }, [user, isLoading, redirectTo, throwIfMissing]);

    return {
        user,
        isLoading,
        isReady: !isLoading && !!user,
    };
}

// const { user, isReady } = useRequireUser();

// if (!isReady) return null; // or loading spinner
