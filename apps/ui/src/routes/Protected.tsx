// A wrapper component that protects child routes based on auth and roles.
import React from "react";
import { Navigate } from "@tanstack/react-router";
import type { UserRole } from "@universal/models";
import { useUser } from "@universal/auth/useUser";
import { useHasRole } from "@universal/auth";

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
  const { user } = useUser();
  const hasRole = useHasRole(roles);

  // User must be authenticated
  if (!user) {
    return <Navigate to={redirectTo} />;
  }

  // If specific roles are required, user must have at least one
    if (!hasRole) {
        return <>{unauthorizedFallback}</>;
    }

  return <>{children}</>;
}
