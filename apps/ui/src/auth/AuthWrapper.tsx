import { useAutoSignin } from "react-oidc-context";

export function AuthWrapper({ children }: { children: React.ReactNode }) {
  if (import.meta.env.VITE_FAKE_AUTH === "true") {
    return <>{children}</>;
  }

  const { isLoading, isAuthenticated, error } = useAutoSignin({
    signinMethod: "signinRedirect",
  });

  if (isLoading) return <div>Signing you in...</div>;
  if (error) return <div>Auth error: {error.message}</div>;

  return <>{children}</>;
}
