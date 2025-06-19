// Protected route for the admin page.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import type { ComponentType } from "react";
import { lazy, Suspense } from "react";
import Protected from "./Protected";
import { PageLoader } from "@universal/components";
import type { FC } from "react";

const LazyAdmin = lazy(() =>
  import("../pages/Admin.js").then((mod) => mod as unknown as { default: ComponentType<FC> })
);

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
