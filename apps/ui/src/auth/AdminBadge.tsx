// Small helper component that shows an "Admin" badge when the user has the admin role.
import { useHasRole } from "@universal/auth";

export function AdminBadge() {
  const isAdmin = useHasRole(["admin"]);

  if (!isAdmin) return null;

  return <span className="badge">👑 Admin</span>;
}
