// User roles used throughout the system
export enum UserRole {
    Superuser = "superuser", // Full override access (root-like)
    Admin = "admin", // Application or org-level admin
    Editor = "editor", // Can modify content but not users
    Viewer = "viewer", // Read-only access
    Contributor = "contributor", // Can submit content but not publish
    Manager = "manager", // High-level non-technical role (e.g. dashboard-only)
    Analyst = "analyst", // Data-only visibility role
    Developer = "developer", // For internal/staging tools or preview builds
}

// Type guard to validate user roles
export const isUserRole = (role: string): role is UserRole =>
    Object.values(UserRole).includes(role as UserRole);

// Standardized OIDC claims (optional helper for consistent claim access)
export enum OIDCClaim {
    Sub = "sub",
    Name = "name",
    GivenName = "given_name",
    FamilyName = "family_name",
    PreferredUsername = "preferred_username",
    Email = "email",
    EmailVerified = "email_verified",
    Locale = "locale",
    UpdatedAt = "updated_at",
    Picture = "picture",
    RealmAccess = "realm_access",
    ResourceAccess = "resource_access",
    Groups = "groups",
}

// User profile structure from an OIDC token (e.g. Keycloak)
export type UserProfile = {
    sub: string;
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
        roles: UserRole[] | string[];
    };

    resource_access?: {
        [clientId: string]: {
            roles: UserRole[] | string[];
        };
    };

    groups?: string[];

    // Additional custom claims mapped from the ID token
    [claim: string]: unknown;
};

// Optional utility to extract specific claims (strongly typed)
export const getKnownClaims = (profile: UserProfile) => ({
    sub: profile[OIDCClaim.Sub],
    email: profile[OIDCClaim.Email],
    preferredUsername: profile[OIDCClaim.PreferredUsername],
});

export const hasRole = (
    profile: UserProfile,
    role: UserRole,
    source: "realm" | "resource" = "realm",
    clientId?: string
): boolean => {
    if (source === "realm") {
        return profile.realm_access?.roles?.includes(role) ?? false;
    }

    if (source === "resource" && clientId) {
        return (
            profile.resource_access?.[clientId]?.roles?.includes(role) ?? false
        );
    }

    return false;
};
