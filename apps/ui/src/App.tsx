import { RouterProvider } from "@tanstack/react-router";
import { ErrorBoundary } from "react-error-boundary";
import { router } from "@universal/routes";

export default function App() {
  return (
    <ErrorBoundary fallback={<ErrorFallback />}>
      <RouterProvider router={router} />
    </ErrorBoundary>
  );
}

function ErrorFallback() {
  return (
    <div className="flex h-screen items-center justify-center text-red-600 bg-zinc-100 dark:bg-zinc-900">
      <p className="text-lg font-semibold">Oops! Something went wrong.</p>
    </div>
  );
}
