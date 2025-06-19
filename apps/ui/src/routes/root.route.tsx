// Shared layout component used as the root of the router.
import { Outlet } from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/react-router-devtools";
import { MockBanner } from "@universal/components";

export function RootLayout() {
  return (
    <div className="min-h-screen flex flex-col">
      <MockBanner />
      <header className="bg-gray-800 text-white px-4 py-3">
        <nav className="space-x-4">
          <a href="/" onMouseEnter={() => import("../pages/Home.js")}>Home</a>
          <a href="/about" onMouseEnter={() => import("../pages/About.js")}>About</a>
          <a href="/admin" onMouseEnter={() => import("../pages/Admin.js")}>Admin</a>
          <a href="/superadmin" onMouseEnter={() => import("../pages/SuperAdmin.js")}>Super Admin</a>
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
