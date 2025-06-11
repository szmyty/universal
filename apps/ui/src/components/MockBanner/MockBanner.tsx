// Displays a warning banner when running in "fake" authentication mode.
// Useful for local development when Keycloak is not available.
export default function MockBanner() {
  if (import.meta.env.VITE_FAKE_AUTH !== "true") return null;

  return (
    <div className="w-full bg-yellow-100 border-b border-yellow-300 text-yellow-800 px-4 py-2 text-sm text-center z-50">
      🧪 Fake Auth Mode Enabled — No real Keycloak connection
    </div>
  );
}
