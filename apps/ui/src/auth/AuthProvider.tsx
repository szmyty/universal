import { AuthProvider as OIDCProvider } from "react-oidc-context";
import { oidcConfig } from "@universal/config";

export function AuthProvider({ children }: { children: React.ReactNode }) {
  return <OIDCProvider {...oidcConfig}>{children}</OIDCProvider>;
}
