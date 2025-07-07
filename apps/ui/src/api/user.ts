import api from "./client";
import { ApiUser, OIDCUser } from "@universal/models";

// Fetch basic user info from Apache/Keycloak-protected API
export async function fetchOIDCUser(): Promise<OIDCUser> {
    const res = await api.get<OIDCUser>("/me");
    return res.data;
}

// Fetch enriched backend user (e.g., with roles from DB)
export async function fetchApiUser(): Promise<ApiUser> {
    const res = await api.get<ApiUser>("/user"); // Adjust this route if needed
    return res.data;
}
