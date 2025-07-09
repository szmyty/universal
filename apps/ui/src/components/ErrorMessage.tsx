import React from "react";

interface ErrorMessageProps {
  error: unknown;
}

export function ErrorMessage({ error }: ErrorMessageProps): React.JSX.Element {
  const message =
    error instanceof Error ? error.message : "An unknown error occurred.";

  return (
    <div className="bg-red-100 text-red-800 p-4 rounded-md my-4">
      <strong>Error:</strong> {message}
    </div>
  );
}
