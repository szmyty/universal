// Example page accessible only to the `superadmin` role.
import { useAuth } from "@universal/auth";

export default function SuperAdminPanel() {
  const { user, roles } = useAuth();

  return (
    <div className="max-w-4xl mx-auto py-10 space-y-8">
      <h1 className="text-4xl font-bold text-purple-700 flex items-center gap-3">
        🧠 Super Admin Panel
      </h1>

      <p className="text-gray-700 text-lg">
        This panel is only accessible to users with elevated privileges.
        You currently have the following roles:
      </p>

      <ul className="list-disc list-inside text-sm text-gray-900 pl-4">
        {roles.map((role: string) => (
          <li key={role}>{role}</li>
        ))}
      </ul>

      <div className="bg-gray-100 border p-4 rounded">
        <h2 className="font-semibold text-gray-800 mb-2">Current User Info:</h2>
        <pre className="text-sm bg-white p-2 rounded overflow-auto text-left">
          {JSON.stringify(user, null, 2)}
        </pre>
      </div>

      <div className="mt-8">
        <h2 className="text-lg font-medium text-purple-800 mb-2">
          🔧 Admin Tools
        </h2>
        <ul className="space-y-2 text-sm">
          <li className="bg-white border p-3 rounded hover:bg-purple-50 transition">
            Manage user access
          </li>
          <li className="bg-white border p-3 rounded hover:bg-purple-50 transition">
            View system logs
          </li>
          <li className="bg-white border p-3 rounded hover:bg-purple-50 transition">
            Trigger deployment
          </li>
        </ul>
      </div>
    </div>
  );
}
