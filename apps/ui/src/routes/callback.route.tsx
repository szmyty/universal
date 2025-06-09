import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { ComponentType, lazy, Suspense } from "react";
import PageLoader from "@universal/components/PageLoader";

const LazyCallback = lazy(() =>
  import("../pages/Callback.js").then((mod) => mod as unknown as { default: ComponentType<any> })
);

export const callbackRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/callback",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <LazyCallback />
    </Suspense>
  ),
});
