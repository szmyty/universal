// hooks/useUser.ts
import { useQuery } from "@tanstack/react-query";
import { fetchOIDCUser, fetchApiUser } from "@universal/api/user";
import { OIDCUser, ApiUser } from "@universal/models";

export function useOIDCUser() {
    return useQuery<OIDCUser>({
        queryKey: ["oidc-user"],
        queryFn: fetchOIDCUser,
        staleTime: 1000 * 60 * 5, // 5 minutes
        retry: false,
    });
}

export function useApiUser() {
    return useQuery<ApiUser>({
        queryKey: ["api-user"],
        queryFn: fetchApiUser,
        staleTime: 1000 * 60 * 5, // 5 minutes
        retry: false,
    });
}
