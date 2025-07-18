## 🧠 General Task

### 🧭 Objective

Ensure the `svg.json` file used by Kepler GL is publicly accessible by updating the Apache configuration to allow unauthenticated access.

### 🗺️ Plan

- [ ] Add an Apache rule to allow `Require all granted` for `svg.json`
- [ ] Optionally scope the rule to just the `kepler/icons/` directory
- [ ] Restart or reload Apache and verify that accessing `svg.json` no longer returns 401
- [ ] Confirm that the Kepler GL icon loading no longer fails in production

### 🔗 References / Resources

- Apache directive: `Require all granted`
- Error: `401 Unauthorized` when requesting `kepler/icons/svg.json`
- Related: Kepler dropdown fails to show icons in prod due to auth block
