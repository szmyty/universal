// Route definition for the home page.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { lazy, Suspense } from "react";
import { PageLoader } from "@universal/components";

const LazyHome = lazy(() => import("../pages/Home.js").then((mod) => ({ default: mod.default })));

export const homeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <LazyHome />
    </Suspense>
  ),
});
