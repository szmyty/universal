## 🧠 General Task

### 🧭 Objective

Complete the TypeScript migration and typing for all remaining JavaScript modules to ensure full type safety and allow the build checker (e.g., `tsc` or `vite-plugin-checker`) to pass without errors.

### 🗺️ Plan

- [ ] Identify any remaining `.js` or partially-typed `.ts` files in the project
- [ ] Add or refine TypeScript types for components, props, hooks, etc.
- [ ] Fix implicit `any`, missing imports, and unsafe access patterns
- [ ] Run `tsc --noEmit` or `vite check` and confirm a clean pass

### 🔗 References / Resources

- TypeScript config: `tsconfig.json`
- Tool: `vite-plugin-checker` (in `vite.config.ts`)
- Optional tool: `ts-migrate`, `ts-prune`, or `typescript-eslint`
