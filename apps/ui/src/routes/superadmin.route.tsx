// Route restricted to superadmin users.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import type { ComponentType } from "react";
import { lazy, Suspense } from "react";
import Protected from "./Protected";
import { PageLoader } from "@universal/components";
import NoAccess from "@universal/pages/NoAccess";
import type { FC } from "react";

const LazySuperAdmin = lazy(() =>
  import("../pages/SuperAdmin.js").then((mod) => mod as unknown as { default: ComponentType<FC> })
);

export const superAdminRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/superadmin",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <Protected roles={["superadmin"]} unauthorizedFallback={<NoAccess />}>
        <LazySuperAdmin />
      </Protected>
    </Suspense>
  ),
});
