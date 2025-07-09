import api from "./client";
import type { ApiUser, OIDCUser } from "@universal/models";
import type { AxiosError } from "axios";

// Fetch basic user info from Apache/Keycloak-protected API
export async function fetchOIDCUser(): Promise<OIDCUser> {
    const url = "/me";

    try {
        console.log(`Requesting: GET ${url}`);
        const response = await api.get<OIDCUser>(url);

        console.log(`Success: ${response.status}`);
        console.log("Response data:", response.data);

        return response.data;
    } catch (error) {
        const axiosError = error as AxiosError;
        if (axiosError.response) {
            // The request was made and the server responded with a status code
            console.error(
                `Error ${axiosError.config?.method?.toUpperCase()} ${axiosError.config?.url})`,
            );
            console.error(
                `Status: ${axiosError.response.status}: ${axiosError.response.statusText}`,
            );
        } else if (axiosError.request) {
            // The request was made but no response was received
            console.error(`No response received for ${url}`);
            console.log(axiosError.request);
        } else {
            // Something happened in setting up the request that triggered an Error
            console.error("Error in setting up request:", axiosError.message);
        }

        console.error("Failed to fetch OIDC user:", error);
        throw error; // Let React Query handle the error
    }
}

// Fetch enriched backend user (e.g., with roles from DB)
export async function fetchApiUser(): Promise<ApiUser> {
    const res = await api.get<ApiUser>("/user"); // Adjust this route if needed
    return res.data;
}
