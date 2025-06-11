// Route restricted to superadmin users.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { ComponentType, lazy, Suspense } from "react";
import Protected from "./Protected";
import PageLoader from "@universal/components/PageLoader";
import NoAccess from "@universal/pages/NoAccess";

const LazySuperAdmin = lazy(() =>
  import("../pages/SuperAdminPanel.js").then((mod) => mod as unknown as { default: ComponentType<any> })
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
