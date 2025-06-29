// Route restricted to superadmin users.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { lazy, Suspense } from "react";
import Protected from "./Protected";
import { PageLoader } from "@universal/components";
import NoAccess from "@universal/pages/NoAccess";
import { UserRole } from "@universal/models";

const LazySuperAdmin = lazy(() =>
  import("../pages/SuperAdmin.js").then((mod) => ({ default: mod.default }))
);

export const superAdminRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/superadmin",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <Protected roles={[UserRole.Superuser]} unauthorizedFallback={<NoAccess />}>
        <LazySuperAdmin />
      </Protected>
    </Suspense>
  ),
});
