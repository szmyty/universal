import axios from "axios";
import { config } from "@universal/config";

const api = axios.create({
    baseURL: config.api.baseUrl,
    withCredentials: true, // Include cookies for CORS requests
});

export default api;
