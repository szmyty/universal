import { useAuth } from "@universal/auth";
// Handles the redirect after Keycloak sign-in.

export default function Callback() {
  const { activeNavigator, isLoading } = useAuth();

  if (activeNavigator === "signinRedirect") {
    return <div>Redirecting...</div>;
  }

  return <div>{isLoading ? "Loading auth..." : "Signed in successfully."}</div>;
}
