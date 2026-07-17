## 1. Record and regression test

- [x] 1.1 <!-- TDD --> Record the upstream root cause and define the completion contract in the OpenSpec proposal, design, and spec.
- [x] 1.2 <!-- TDD --> Add a smoke test that runs `npm run publish:offline` and rejects empty or incomplete HTML.
- [x] 1.3 <!-- TDD --> Run the smoke test against the existing command and capture the expected 0-byte failure.

## 2. Reliable publisher

- [x] 2.1 <!-- TDD --> Add `Wiki/scripts/publish-offline.mjs` with the existing plugin collection and TiddlyWiki offline render flow.
- [x] 2.2 <!-- TDD --> Add bounded polling for non-empty, complete, stable HTML before temporary directory cleanup.
- [x] 2.3 <!-- Non-TDD --> Point `Wiki/package.json` `publish:offline` at the project-level wrapper without changing other scripts.

## 3. Verification and synchronization

- [x] 3.1 <!-- TDD --> Run the offline publish smoke test and confirm the generated HTML is non-empty and complete.
- [x] 3.2 <!-- Non-TDD --> Run `npm run check` and `npm run build` in `Wiki/`.
- [x] 3.3 <!-- Non-TDD --> Run `openspec validate "fix-tw-offline-publish-output" --type change --strict`.
- [x] 3.4 <!-- Non-TDD --> Update `feature-tw-angelscript-theme` verification/task records with the completed offline publish check.
