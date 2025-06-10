// src/routes/Protected.tsx
import { Navigate } from "@tanstack/react-router";
import { useAuth } from "../auth/useAuth";

export type ProtectedProps = {
  roles?: string[];
  unauthorizedFallback?: React.ReactNode;
  children: React.ReactNode;
}

export default function Protected({
  roles,
  unauthorizedFallback = <div className="text-red-500">Access Denied</div>,
  children,
}: ProtectedProps) {
  const { isAuthenticated, roles: userRoles } = useAuth();

  // Must be logged in
  if (!isAuthenticated) {
    return <Navigate to="/" />;
  }

  // Must match at least one role if roles are specified
  if (roles?.length && !roles.some((role) => userRoles.includes(role))) {
    return <>{unauthorizedFallback}</>;
  }

  return <>{children}</>;
}
