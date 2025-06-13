// MockBanner displays a persistent banner whenever the application is running
// in "fake" authentication mode.  This is primarily useful during local
// development when Keycloak or another OIDC provider is not available.
//
// The component renders nothing when real authentication is enabled.
export default function MockBanner() {
  if (import.meta.env.VITE_FAKE_AUTH !== "true") return null;

  return (
    <div className="w-full bg-yellow-100 border-b border-yellow-300 text-yellow-800 px-4 py-2 text-sm text-center z-50">
      🧪 Fake Auth Mode Enabled — No real Keycloak connection
    </div>
  );
}
