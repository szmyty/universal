import { createContext, useContext } from "react";
import type { ReactNode } from "react";
import type { UserProfile } from "@universal/models";
import { mockUser } from "@universal/models";

// Shared type for real and mock auth
export type AuthContextValue = {
  isAuthenticated: boolean;
  isLoading: boolean;
  login: () => void;
  logout: () => void;
  user?: UserProfile;
  accessToken?: string;
  roles: string[];
  activeNavigator?: string | null;
  error?: unknown;
};

const MockAuthContext = createContext<AuthContextValue | undefined>(undefined);

export function MockAuthProvider({ children }: { children: ReactNode }) {
  const mockContext: AuthContextValue = {
    isAuthenticated: true,
    isLoading: false,
    login: () => alert("stub login"),
    logout: () => alert("stub logout"),
    user: mockUser,
    accessToken: "fake-token",
    roles: mockUser.realm_access?.roles ?? [],
    activeNavigator: null,
    error: null,
  };

  return (
    <MockAuthContext.Provider value={mockContext}>
      {children}
    </MockAuthContext.Provider>
  );
}

export function useMockAuth(): AuthContextValue {
  const context = useContext(MockAuthContext);
  if (!context) {
    throw new Error("useMockAuth must be used within a MockAuthProvider");
  }
  return context;
}
