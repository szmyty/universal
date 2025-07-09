## 🧠 General Task

### 🧭 Objective

Set up `changesets` in the monorepo to handle versioning and changelog generation for all packages. This will be used as part of the CI/CD pipeline to update versions automatically during deployments to demo and production environments.

### 🗺️ Plan

- [ ] Finalize `.changeset/config.json` configuration
- [ ] Ensure all packages in the monorepo are included
- [ ] Configure release script (manual or CI-based) to bump versions and generate changelogs
- [ ] Integrate with GitHub Actions or CI to handle version bumps on `main`, triggering deployment
- [ ] Test the release flow with a canary or patch version
- [ ] Add documentation for future contributors on how to use changesets

### 🔗 References / Resources

- https://github.com/changesets/changesets
- [`pnpm` changeset setup guide](https://github.com/changesets/changesets/blob/main/docs/pnpm.md)
- `.changeset/config.json` file already added (needs review)
