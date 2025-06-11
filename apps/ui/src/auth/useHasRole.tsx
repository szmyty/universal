// Utility hooks for checking user roles and groups.
import { useAuth } from "./useAuth";

/**
 * Returns whether the current user has at least one of the given roles.
 * If no roles are provided, returns true if the user is authenticated.
 */
export function useHasRole(requiredRoles?: string[]): boolean {
  const { isAuthenticated, roles: userRoles } = useAuth();

  if (!isAuthenticated) return false;

  if (!requiredRoles || requiredRoles.length === 0) {
    return true; // any authenticated user
  }

  return requiredRoles.some((role) => userRoles.includes(role));
}

export function useIsAdmin() {
  return useIsInGroup("admin");
}

export function useIsInGroup(groupName: string) {
  const { user } = useAuth();
  return user?.groups?.includes(groupName) ?? false;
}
