// models/user.mock.ts
import type { UserProfile} from "./user";
import { UserRole } from "./user";

export const mockUser: UserProfile = {
    sub: "mock-user-id",
    name: "Jane Doe",
    preferred_username: "janedoe",
    email: "jane@example.com",
    email_verified: true,
    locale: "en-US",
    picture: "https://placekitten.com/128/128",
    realm_access: {
        roles: [UserRole.Superuser, UserRole.Admin],
    },
    resource_access: {
        frontend: {
            roles: [UserRole.Editor],
        },
    },
    groups: ["/admin", "/beta-testers"],
    "custom:plan": "pro",
};
