// PageLoader displays a placeholder spinner while a route component is
// being lazily loaded.  This keeps layout shifts to a minimum during
// asynchronous navigation.
export default function PageLoader() {
  return (
    <div className="flex items-center justify-center h-64 text-gray-500">
      <div className="animate-pulse text-lg">Loading...</div>
    </div>
  );
}
