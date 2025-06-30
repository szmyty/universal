import { useUser } from "@universal/auth";
import { Button, MapStateManager } from "@universal/components";
import { useApiHealth } from "@universal/hooks";

// Simple helper to display key-value pairs
const UserInfoRow = ({ label, value }: { label: string; value?: string | string[] }) => {
  return (
    <div>
      <strong>{label}:</strong>{" "}
      {Array.isArray(value) ? value.join(", ") : value || "—"}
    </div>
  );
};

export default function Home() {
  const status = useApiHealth();
  const { user, isLoading, error } = useUser();

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-3xl font-bold">🏡 Home</h1>

      <p>
        API Health:{" "}
        {status === "loading"
          ? "⏳ Checking..."
          : status === "ok"
          ? "✅ Healthy"
          : "❌ Unreachable"}
      </p>

      <div>
        <h2 className="text-xl font-semibold">🧑 User Info</h2>
        {isLoading && <p>Loading user...</p>}
        {error && <p className="text-red-600">Error loading user: {error.message}</p>}
        {user && (
          <div className="space-y-1">
            <UserInfoRow label="Username" value={user.preferred_username} />
            <UserInfoRow label="Name" value={user.name} />
            <UserInfoRow label="Email" value={user.email} />
            <UserInfoRow label="Locale" value={user.locale} />
            <UserInfoRow label="Roles" value={user.realm_access?.roles ?? []} />
            <UserInfoRow label="Groups" value={user.groups ?? []} />
          </div>
        )}
      </div>

      <Button onClick={() => alert("Hello!")}>Say Hi</Button>

      <div>
        <h2 className="text-xl font-semibold">🗺️ Map States</h2>
        <MapStateManager />
      </div>
    </div>
  );
}
