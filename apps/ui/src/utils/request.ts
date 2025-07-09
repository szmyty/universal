import api from "@universal/api/client";
import type {
    AxiosError,
    AxiosRequestConfig,
    AxiosResponse,
    Method,
} from "axios";

/**
 * Generic typed API request with logging and error handling.
 */
export async function request<T>(
    method: Method,
    url: string,
    payload?: unknown,
    options?: AxiosRequestConfig,
): Promise<T> {
    try {
        console.log(`Requesting: ${method.toUpperCase()} ${url}`);
        if (payload) {
            console.log("Payload:", payload);
        }

        const response: AxiosResponse<T, unknown> = await api.request<T>({
            url,
            method,
            data: payload,
            ...options,
        });

        console.log(`Success: ${response.status}`);
        console.log("Response:", response.data);

        return response.data;
    } catch (error) {
        const axiosError = error as AxiosError;

        if (axiosError.response) {
            console.error(
                `Error ${axiosError.config?.method?.toUpperCase()} ${axiosError.config?.url}`,
            );
            console.error(
                `Status: ${axiosError.response.status} ${axiosError.response.statusText}`,
            );
        } else if (axiosError.request) {
            console.error(`No response received for ${url}`);
            console.log(axiosError.request);
        } else {
            console.error("Error in setting up request:", axiosError.message);
        }

        console.error("Final error object:", error);
        throw error;
    }
}

export const get = <T>(url: string, options?: AxiosRequestConfig) =>
    request<T>("GET", url, undefined, options);

export const post = <T>(
    url: string,
    data?: unknown,
    options?: AxiosRequestConfig,
) => request<T>("POST", url, data, options);

export const put = <T>(
    url: string,
    data?: unknown,
    options?: AxiosRequestConfig,
) => request<T>("PUT", url, data, options);

export const del = <T>(url: string, options?: AxiosRequestConfig) =>
    request<T>("DELETE", url, undefined, options);
