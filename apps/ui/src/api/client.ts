import axios from "axios";
import type { AxiosInstance } from "axios";
import { config } from "@universal/config";

const api: AxiosInstance = axios.create({
    baseURL: config.api.baseUrl,
    withCredentials: true, // Include cookies for CORS requests
});

export default api;
