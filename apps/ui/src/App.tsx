// Root application component used by `main.tsx`.
// It wires up the TanStack router and catches rendering errors.
import { RouterProvider } from "@tanstack/react-router";
import { ErrorBoundary } from "react-error-boundary";
import { router } from "./routes";

export default function App() {
  // The router handles all page rendering. If a rendering error occurs
  // we display a generic fallback to avoid a blank screen.
  return (
    <ErrorBoundary fallback={<div>Something went wrong.</div>}>
      <RouterProvider router={router} />
    </ErrorBoundary>
  );
}
