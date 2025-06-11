// Application entry point. Sets up global providers and mounts React to the DOM.
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { AuthProvider, AuthWrapper, MockAuthProvider } from "@universal/auth";
import "./styles/global.css";

// Swap in a mock auth provider when fake auth mode is enabled.
const Provider = import.meta.env.VITE_FAKE_AUTH === "true"
  ? MockAuthProvider
  : AuthProvider;

// Render the root component tree under <div id="root"> in index.html.
ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <Provider>
      <AuthWrapper>
        <App />
      </AuthWrapper>
    </Provider>
  </React.StrictMode>
);
