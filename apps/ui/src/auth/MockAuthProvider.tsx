// Lightweight replacement for `react-oidc-context` used during local development.
import { createContext, useContext } from "react";
import type { UserProfile } from "@universal/models";

const MockAuthContext = createContext<any>(null);

const mockUser: UserProfile = {
  sub: "123",
  name: "Dev User",
  email: "dev@example.com",
  preferred_username: "dev",
  realm_access: {
    roles: ["admin"],
  },
};

export function MockAuthProvider({ children }: { children: React.ReactNode }) {
  return (
    <MockAuthContext.Provider
      value={{
        isAuthenticated: true,
        isLoading: false,
        login: () => alert("stub login"),
        logout: () => alert("stub logout"),
        user: mockUser,
        accessToken: "fake-token",
        roles: mockUser.realm_access?.roles ?? [],
        activeNavigator: null,
        error: null,
      }}
    >
      {children}
    </MockAuthContext.Provider>
  );
}

export function useMockAuth() {
  return useContext(MockAuthContext);
}
