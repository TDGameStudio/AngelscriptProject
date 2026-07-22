## Verification snapshot

Verified on 2026-07-23 from the main workspace checkout.

- `openspec validate improve-wiki-search-experience --strict` — PASS
- `npm run lint` — PASS
- `npx eslint scripts/dev-external-plugin-sources.mjs scripts/watch-external-plugin-sources.mjs scripts/external-plugin-sources.test.mjs` — PASS
- `npm run check` — PASS
- `npm run test:external-plugins` — PASS (`7/7`)
- `npm test` — PASS (`1/1` plugin spec)
- `npm run build` — PASS (nine selected runtime plugins; preview glass absent)
- `npm run test:publish:offline` — PASS (`1/1`)
- `npm run test:playwright` — PASS (`20/20`)
- Real-source development watcher add/remove probe — PASS; both operations reached the running Wiki and generated bridge without a manual prepare or restart.
- Desktop and narrow command-palette layouts, direct AngelScript source rendering, and the expanded seven-group syntax gallery were visually inspected from the running product Wiki.

The unrelated template-plugin `test:examples` suite cannot share the running product's port: its default configuration reuses port 8080 and therefore opens the product Wiki, where the placeholder `$:/plugins/your-name/plugin-name` is intentionally excluded. An isolated template server also hit the upstream development server's zero-change startup path and never established its listener. Product Playwright coverage does not depend on that placeholder plugin.
