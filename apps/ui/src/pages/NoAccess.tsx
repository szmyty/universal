// Displayed when a user lacks sufficient permissions.
import { useAuth, AdminBadge } from "@universal/auth";

export default function NoAccess() {
  const { user, isAuthenticated, roles } = useAuth();

  return (
    <div className="max-w-xl mx-auto text-center py-20">
      <h1 className="text-4xl font-bold text-red-600 mb-4">🚫 Access Denied</h1>

      <p className="text-gray-700 mb-6">
        You do not have permission to view this page.
      </p>

      {isAuthenticated ? (
        <div className="bg-gray-100 p-4 rounded border">
          <p className="mb-2 font-medium">Logged in as:</p>
          <pre className="text-sm bg-white p-2 rounded overflow-auto text-left">
            {JSON.stringify(user, null, 2)}
          </pre>

          <div className="mt-4">
            Your roles:{" "}
            <span className="font-mono text-sm text-gray-800">
              {roles.join(", ")}
            </span>{" "}
            <AdminBadge />
          </div>
        </div>
      ) : (
        <div className="text-gray-600">
          You are not logged in. Please log in to access protected pages.
        </div>
      )}
    </div>
  );
}
