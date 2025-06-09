import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import { AuthProvider, AuthWrapper, MockAuthProvider } from "@universal/auth";
import "./styles/global.css";

const Provider = import.meta.env.VITE_FAKE_AUTH === "true"
  ? MockAuthProvider
  : AuthProvider;

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <Provider>
      <AuthWrapper>
        <App />
      </AuthWrapper>
    </Provider>
  </React.StrictMode>
);
