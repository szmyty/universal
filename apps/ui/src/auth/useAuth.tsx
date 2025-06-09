import type { UserProfile } from "@universal/models";
import { useMockAuth } from "./MockAuthProvider";

export function useAuth() {
  if (import.meta.env.VITE_FAKE_AUTH === "true") {
    return useMockAuth();
  }

  // 👇 only import after the check
  const { useAuth: useOIDC } = require("react-oidc-context");
  const auth = useOIDC();
  const profile = auth.user?.profile as UserProfile;

  return {
    isAuthenticated: auth.isAuthenticated,
    isLoading: auth.isLoading,
    login: auth.signinRedirect,
    logout: auth.signoutRedirect ?? auth.removeUser,
    user: profile,
    accessToken: auth.user?.access_token,
    roles: profile?.realm_access?.roles ?? [],
    activeNavigator: auth.activeNavigator,
    error: auth.error,
  };
}
