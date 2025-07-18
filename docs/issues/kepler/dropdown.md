## 🧠 General Task

### 🧭 Objective

Ensure the "Map" dropdown triggers a fresh API call when clicked, so the list of available maps is always up to date (reflecting any new ones created).

### 🗺️ Plan

- [ ] Refactor the dropdown's onClick handler to invoke a `fetchMaps()` function
- [ ] Ensure any cached map state is cleared or refreshed
- [ ] Confirm the dropdown reflects new maps without requiring full page reload
- [ ] Optionally debounce or lock the fetch if needed to avoid duplicate requests

### 🔗 References / Resources

- Related message: "dropdown needs to refresh and call the API"
- Example usage: `GET /api/maps` or equivalent client query
