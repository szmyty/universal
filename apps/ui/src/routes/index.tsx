import { createRootRoute, createRouter } from "@tanstack/react-router";
import { RootLayout } from "./root.route";
import { homeRoute } from "./home.route";
import { aboutRoute } from "./about.route";
import { adminRoute } from "./admin.route";
import { callbackRoute } from "./callback.route";
import { lazy, Suspense } from "react";
import type { ComponentType } from "react";
import PageLoader from "@universal/components/PageLoader";
import { superAdminRoute } from "./super_admin.route";

// ✅ Safely lazy-load NotFound with correct type casting
const LazyNotFound = lazy(() =>
  import("../pages/NotFound.js").then(
    (mod) => mod as unknown as { default: ComponentType<any> }
  )
);

function NotFoundComponent() {
  return (
    <Suspense fallback={<PageLoader />}>
      <LazyNotFound />
    </Suspense>
  );
}

// ✅ Root route uses layout + suspense-wrapped notFoundComponent
export const rootRoute = createRootRoute({
  component: RootLayout,
  notFoundComponent: NotFoundComponent,
});

export const routeTree = rootRoute.addChildren([
  homeRoute,
  aboutRoute,
  adminRoute,
  superAdminRoute,
  callbackRoute
]);

export const router = createRouter({ routeTree });
