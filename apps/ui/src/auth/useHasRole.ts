// src/auth/useHasRole.ts
// Utility hooks for checking user roles and groups.

import { useAuth } from "./useAuth";
import type { UserRole } from "@universal/models/user";

/**
 * Returns true if the current user has any of the required roles.
 * If no roles are specified, returns true if the user is authenticated.
 */
export function useHasRole(requiredRoles?: UserRole[] | string[]): boolean {
    const { isAuthenticated, roles: userRoles } = useAuth();

    if (!isAuthenticated) return false;

    if (!requiredRoles || requiredRoles.length === 0) {
        return true; // any authenticated user is valid
    }

    return requiredRoles.some((role) => userRoles.includes(role));
}

/**
 * Checks if the current user has the "admin" group.
 * Used for group-based access control.
 */
export function useIsAdmin(): boolean {
    return useIsInGroup("admin");
}

/**
 * Checks if the current user is in the specified group.
 */
export function useIsInGroup(groupName: string): boolean {
    const { user } = useAuth();
    return user?.groups?.includes(groupName) ?? false;
}
