// Route definition for the home page.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { ComponentType, lazy, Suspense } from "react";
import PageLoader from "@universal/components/PageLoader";

const LazyHome = lazy(() =>
  import("../pages/Home.js").then((mod) => mod as unknown as { default: ComponentType<any> })
);

export const homeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <LazyHome />
    </Suspense>
  ),
});
