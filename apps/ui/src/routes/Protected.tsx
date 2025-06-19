// A wrapper component that protects child routes based on auth and roles.
import React from "react";
import { Navigate } from "@tanstack/react-router";
import { useAuth } from "@universal/auth";
import type { UserRole } from "@universal/models";

export type ProtectedProps = {
  roles?: UserRole[] | string[];
  unauthorizedFallback?: React.ReactNode;
  redirectTo?: string;
  children: React.ReactNode;
};

export default function Protected({
  roles,
  redirectTo = "/",
  unauthorizedFallback = <div className="text-red-500">Access Denied</div>,
  children,
}: ProtectedProps) {
  const { isAuthenticated, roles: userRoles } = useAuth();

  // User must be authenticated
  if (!isAuthenticated) {
    return <Navigate to={redirectTo} />;
  }

  // If specific roles are required, user must have at least one
  if (roles?.length && !roles.some((role) => userRoles.includes(role))) {
    return <>{unauthorizedFallback}</>;
  }

  return <>{children}</>;
}
