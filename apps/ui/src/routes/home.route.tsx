// Route definition for the home page.
import { createRoute } from "@tanstack/react-router";
import { rootRoute } from "./index";
import type { ComponentType } from "react";
import { lazy, Suspense } from "react";
import { PageLoader } from "@universal/components";
import type { FC } from "react";

const LazyHome = lazy(() =>
  import("../pages/Home.js").then((mod) => mod as unknown as { default: ComponentType<FC> })
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
