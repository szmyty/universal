// Protected route for the admin page.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { lazy, Suspense } from "react";
import Protected from "./Protected";
import { PageLoader } from "@universal/components";

const LazyAdmin = lazy(() => import("../pages/Admin.js"));

export const adminRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/admin",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <Protected roles={["admin"]}>
        <LazyAdmin />
      </Protected>
    </Suspense>
  ),
});
