// src/auth/useAuth.ts
import { useContext } from "react";
import { AuthContext } from "react-oidc-context";
import type { AuthContextValue } from "./MockAuthProvider";
import { useMockAuth } from "./MockAuthProvider";
import { isAuthEnabled } from "@universal/config";
import type { UserProfile } from "@universal/models";

/**
 * Returns the unified auth context depending on environment config.
 * Real auth context when VITE_ENABLE_AUTH=true, otherwise mock.
 */
export function useAuth(): AuthContextValue {
    if (!isAuthEnabled()) {
        return useMockAuth();
    }

    const context = useContext(AuthContext);

    if (!context) {
        throw new Error("useAuth must be used within an AuthProvider");
    }

    const profile = context.user?.profile as UserProfile | undefined;

    return {
        isAuthenticated: context.isAuthenticated,
        isLoading: context.isLoading,
        login: context.signinRedirect,
        logout: context.signoutRedirect ?? context.removeUser,
        user: profile,
        accessToken: context.user?.access_token,
        roles: profile?.realm_access?.roles ?? [],
        activeNavigator: context.activeNavigator,
        error: context.error,
    };
}
