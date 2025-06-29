# 🌐 Universal React

A clean, scalable, and DX-first React template powered by:

- 🧠 TypeScript + Vite + React 19
- ⚛️ TanStack Router + Tailwind CSS
- 🔐 Optional real or mock OIDC Auth (Keycloak-ready)
- 🧪 Vitest + Testing Library
- 🛠️ Linting, formatting, and task automation baked in
- 📦 ASDF-managed toolchain (Node, PNPM, Python, Go, etc.)

---

## 🚀 Quick Start

```shell
git clone https://github.com/your-username/universal-react
cd universal-react
```

---

## ⚙️ Tooling Setup

This project uses **ASDF** + **Taskfile** for reproducible environments and DX automation.

### ✅ 1. Install Required Tools

**asdf (version manager)**

```shell
brew install asdf
```

**task (task runner)**

```
brew install go-task/tap/go-task
```

**asdf plugins (declared in `.tool-versions`)**

```
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add pnpm https://github.com/jonathanmorley/asdf-pnpm.git
asdf plugin add python
asdf plugin add poetry
asdf plugin add golang
asdf plugin add rust
```

**Install all versions**

```
asdf install
```

---

## 📦 Project Setup

Once toolchain is installed:

```
task install
```

---

## 🧪 Local Development

```
task dev
```

---

## ⚙️ Build & Preview Production

```
task preview
```

---

## 🧼 Code Quality

```
task lint        # Lint code (ESLint flat config + Prettier-ready)
task format      # Format with Prettier
task typecheck   # Type check with TS
task test        # Run Vitest tests
```

---

## 🔐 Authentication

This template supports:

- Real OIDC (via Keycloak) → set `MOCK_AUTH=false`
- Mock Auth for local/dev → default mode

Control this in `src/config/runtime.ts`.

---

## 📁 Folder Structure

```shell
.
├── src/
│ ├── auth/ # Real + mock auth contexts
│ ├── components/ # UI components
│ ├── models/ # Shared data models
│ ├── pages/ # Route components
│ ├── routes/ # TanStack router config
│ ├── styles/ # Tailwind entry
│ ├── tests/ # Test setup
├── public/ # Static files
├── Taskfile.yml # Task runner automation
├── .tool-versions # ASDF toolchain declaration
├── vite.config.mts # Vite + plugins
```

---

## 🧪 Testing

- **Vitest + @testing-library/react**
- `tests/setup.ts` preloads globals
- `task test` runs your suite

---

## 📌 License

MIT © [Alan Szmyt](https://github.com/szmyty)
