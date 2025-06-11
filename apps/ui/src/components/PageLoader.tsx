// Simple loading indicator used when lazily loading pages.
export default function PageLoader() {
  return (
    <div className="flex items-center justify-center h-64 text-gray-500">
      <div className="animate-pulse text-lg">Loading...</div>
    </div>
  );
}
