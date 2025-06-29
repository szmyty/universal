// Landing page displayed at the root URL.
import { Button } from "@universal/components";
import { useApiHealth } from "@universal/hooks";

// The Home page is a minimal landing screen.  It showcases use of the shared
// `Button` component as an example.
export default function Home() {
  const status = useApiHealth();

  return (
    <div>
      <h1>Welcome to the Home Page</h1>
        <p>
        API Health:{" "}
        {status === "loading"
          ? "⏳ Checking..."
          : status === "ok"
          ? "✅ Healthy"
          : "❌ Unreachable"}
        </p>
        <div className="space-y-4">
      <h1 className="text-3xl font-bold">🏡 Home</h1>
      <Button onClick={() => alert("Hello!")}>Say Hi</Button>
    </div>
    </div>
  );
}
