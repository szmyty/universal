import { useMemo } from "react";
import type { UserProfile } from "@universal/models";
import { UserRole } from "@universal/models";

export function useUser(): { user: UserProfile } {
    const user = useMemo<UserProfile>(
        () => ({
            sub: "mock-sub-1234",
            preferred_username: "mockuser",
            email: "mockuser@example.com",
            given_name: "Mock",
            family_name: "User",
            name: "Mock User",
            picture: "https://avatars.githubusercontent.com/u/000000?v=4",
            locale: "en-US",
            updated_at: Date.now(),
            realm_access: {
                roles: [UserRole.Superuser, UserRole.Developer, UserRole.Admin],
            },
            resource_access: {
                "my-client-id": {
                    roles: [UserRole.Admin],
                },
            },
            groups: ["mock-group"],
        }),
        [],
    );

    return { user };
}
