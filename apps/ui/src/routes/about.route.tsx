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


import React from "react";
import Lottie from "react-lottie-player";
import animationData from "@/assets/animations/loading.json"; // adjust path if needed

export default function PageLoader() {
  return (
    <div className="flex items-center justify-center h-64">
      <Lottie
        loop
        play
        animationData={animationData}
        style={{ width: 120, height: 120 }}
      />
    </div>
  );
}
