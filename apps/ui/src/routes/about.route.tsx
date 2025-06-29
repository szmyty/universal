// Route definition for the about page.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import { lazy, Suspense } from "react";
import { PageLoader } from "@universal/components";

const LazyAbout = lazy(() => import("../pages/About.js"));

export const aboutRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/about",
  component: () => (
    <Suspense fallback={<PageLoader />}>
      <LazyAbout />
    </Suspense>
  ),
});
