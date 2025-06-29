// Route used after completing the OIDC login flow.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { lazy, Suspense } from "react";
import { PageLoader } from "@universal/components";

const LazyCallback = lazy(() => import("../pages/Callback.js"));

export const callbackRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/callback",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <LazyCallback />
    </Suspense>
  ),
});
