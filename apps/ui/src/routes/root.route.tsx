import { Outlet } from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/react-router-devtools";
import MockBanner from "@universal/components//MockBanner/MockBanner";

export function RootLayout() {
  return (
    <div className="min-h-screen flex flex-col">
      <MockBanner />
      <header className="bg-gray-800 text-white px-4 py-3">
        <nav className="space-x-4">
          <a href="/">Home</a>
          <a href="/about">About</a>
          <a href="/admin">Admin</a>
        </nav>
      </header>

      <main className="flex-grow p-4">
        <Outlet />
      </main>

      <footer className="bg-gray-100 text-center p-2 text-sm text-gray-600">
        © 2025 Universal DX
      </footer>

      {import.meta.env.DEV && <TanStackRouterDevtools position="bottom-right" />}
    </div>
  );
}
