import { AdminBadge, useUser } from "@universal/auth";

// Simple informational page.
export default function About() {
    const { user } = useUser();
    return (
        <div className="space-y-4">
            <h1 className="text-3xl font-bold text-blue-600">ℹ️ About Panel</h1>
              {user ? (
                <div className="bg-gray-100 p-4 rounded border">
                  <p className="mb-2 font-medium">Logged in as:</p>
                  <pre className="text-sm bg-white p-2 rounded overflow-auto text-left">
                    {JSON.stringify(user, null, 2)}
                  </pre>

                  <div className="mt-4">
                    Your roles:{" "}
                    <span className="font-mono text-sm text-gray-800">
                      {user.realm_access?.roles.join(", ")}
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
    )
}
