import { useEffect, useMemo, useState } from "react";
import axios from "axios";
import { config } from "@universal/config";

export type ApiHealthStatus = "loading" | "ok" | "error";

export function useApiHealth(endpoint: string = "/health?auto"): ApiHealthStatus {
  const [status, setStatus] = useState<ApiHealthStatus>("loading");

  const healthUrl = useMemo(() => {
    return `${config.api.baseUrl}${endpoint.startsWith("/") ? endpoint : `/${endpoint}`}`;
  }, [endpoint]);

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const response = await axios.get(healthUrl, {
          timeout: 3000,
        });

        setStatus(response.status === 200 ? "ok" : "error");
      } catch (err) {
        setStatus("error");
      }
    };

    checkHealth();
  }, [healthUrl]);

  return status;
}
