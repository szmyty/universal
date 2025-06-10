import { useHasRole } from "../auth/useHasRole";

export function AdminBadge() {
  const isAdmin = useHasRole(["admin"]);

  if (!isAdmin) return null;

  return <span className="badge">👑 Admin</span>;
}
