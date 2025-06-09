import { Navigate } from "@tanstack/react-router";
import { useAuth } from "../auth/useAuth";

export type ProtectedProps = {
  roles?: string[];
  children: React.ReactNode;
}

export default function Protected({ roles, children }: ProtectedProps) {
  const { isAuthenticated, roles: userRoles } = useAuth();

  if (!isAuthenticated) return <Navigate to="/" />;
  if (roles && !roles.some((r) => userRoles.includes(r))) {
    return <div className="text-red-500">Access Denied</div>;
  }

  return <>{children}</>;
}
