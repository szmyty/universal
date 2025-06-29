import { useEffect, useState } from "react";

type ApiHealthStatus = "loading" | "ok" | "error";

export function useApiHealth(apiUrl: string = "/api/health?auto"): ApiHealthStatus {
  const [status, setStatus] = useState<ApiHealthStatus>("loading");

  useEffect(() => {
    const checkHealth = async () => {
      try {
        const res = await fetch(apiUrl);
        setStatus(res.ok ? "ok" : "error");
      } catch {
        setStatus("error");
      }
    };

    checkHealth();
  }, [apiUrl]);

  return status;
}
