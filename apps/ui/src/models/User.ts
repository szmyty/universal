export type UserProfile = {
    sub: string; // subject (user id)
    name?: string;
    given_name?: string;
    family_name?: string;
    preferred_username?: string;
    email?: string;
    email_verified?: boolean;

    locale?: string;
    updated_at?: number;

    picture?: string;

    realm_access?: {
        roles: string[];
    };

    resource_access?: {
        [clientId: string]: {
            roles: string[];
        };
    };

    groups?: string[];

    // Any extra custom attributes from your Keycloak realm's token mapper
    [claim: string]: unknown;
};
