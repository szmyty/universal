import React from "react";
import { AuthProvider as OIDCProvider } from "react-oidc-context";
import { oidcConfig } from "@universal/auth";

export function AuthProvider({ children }: { children: React.ReactNode }) {
  return <OIDCProvider {...oidcConfig}>{children}</OIDCProvider>;
}
