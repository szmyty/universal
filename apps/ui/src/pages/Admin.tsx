// Protected admin page showing user info and roles.
import { useAuth } from "@universal/auth";

export default function Admin() {
  const { user, accessToken, roles, isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <div className="text-red-500">You are not authenticated.</div>;
  }

  return (
    <div className="space-y-4">
      <h1 className="text-3xl font-bold text-blue-600">🔐 Admin Panel</h1>

      <div className="p-4 rounded bg-gray-100 border">
        <h2 className="font-semibold mb-2">User Info</h2>
        <pre className="text-sm bg-white p-2 rounded overflow-auto">
          {JSON.stringify(user, null, 2)}
        </pre>
      </div>

      <div className="p-4 rounded bg-gray-100 border">
        <h2 className="font-semibold mb-2">Access Token</h2>
        <pre className="text-sm bg-white p-2 rounded overflow-auto">
          {accessToken}
        </pre>
      </div>

      <div className="p-4 rounded bg-gray-100 border">
        <h2 className="font-semibold mb-2">Roles</h2>
        <ul className="list-disc pl-6">
          {roles.map((role: string) => (
            <li key={role}>{role}</li>
          ))}
        </ul>
      </div>
    </div>
  );
}
