import type { ReactNode } from "react";
import { isAuthEnabled } from "@universal/config";
import { AuthProvider, MockAuthProvider } from "@universal/auth";

/**
 * Chooses between real or mock auth provider at runtime.
 */
export function UniversalAuthProvider({ children }: { children: ReactNode }) {
  if (!isAuthEnabled()) {
    return <MockAuthProvider>{children}</MockAuthProvider>;
  }

  return <AuthProvider>{children}</AuthProvider>;
}
