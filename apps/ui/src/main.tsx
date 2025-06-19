// Application entry point. Sets up global providers and mounts React to the DOM.
import React from "react";
import ReactDOM from "react-dom/client";
import "@universal/styles/app.css";
import { UniversalAuthProvider } from "@universal/auth";
import App from "./App";

// Render the root component tree under <div id="root"> in index.html.
ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <UniversalAuthProvider>
      <App />
    </UniversalAuthProvider>
  </React.StrictMode>
);
