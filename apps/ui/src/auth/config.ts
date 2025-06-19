// Configuration passed to `react-oidc-context` for Keycloak.
import type { AuthProviderProps } from "react-oidc-context";

export const oidcConfig: AuthProviderProps = {
    authority: import.meta.env.VITE_KEYCLOAK_URL,
    client_id: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
    redirect_uri: window.location.origin + "/callback",
    response_type: "code",
    scope: "openid profile email",

    // Required to clear URL hash on callback
    onSigninCallback: () => {
        window.history.replaceState(
            {},
            document.title,
            window.location.pathname
        );
    },
};
