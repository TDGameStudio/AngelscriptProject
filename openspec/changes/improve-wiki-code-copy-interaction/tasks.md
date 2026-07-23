## 1. OpenSpec and regression coverage

- [x] 1.1 <!-- TDD --> Add desktop visibility, keyboard focus, touch availability, temporary feedback, and repeat-copy assertions to `Wiki/tests/playwright/product/angelscript-code.spec.ts` without undoing its existing staged relocation.
- [x] 1.2 <!-- TDD --> Run the focused product spec before source changes and confirm the desktop idle-visibility assertion fails for the current always-visible button.

## 2. Shared code-block copy interaction

- [x] 2.1 <!-- Non-TDD --> Update `Wiki/src/angelscript-tools/codeblock-copy.ts` with the Heroicons outline clipboard-document idle SVG, a named 1.5-second feedback duration, and latest-attempt-wins state ownership while preserving existing clipboard behavior and localized accessibility labels.
- [x] 2.2 <!-- Non-TDD --> Update `Wiki/src/angelscript-tools/index.css` with low-emphasis default presentation, fine-pointer hover/focus/result visibility, no-hover availability, focus feedback, and reduced-motion compatibility.
- [x] 2.3 <!-- TDD --> Re-run the focused product spec and confirm all code-copy assertions pass.

## 3. Documentation and verification

- [x] 3.1 <!-- Non-TDD --> Update `Wiki/src/angelscript-tools/readme.tid` to document the Copy glyph, adaptive visibility, 1.5-second reset, and repeated-copy behavior without changing the public widget attributes.
- [x] 3.2 <!-- Non-TDD --> Run `npm exec --yes pnpm@11.8.0 -- run check`, `npm exec --yes pnpm@11.8.0 -- run lint`, and `npm exec --yes pnpm@11.8.0 -- exec playwright test tests/playwright/product/angelscript-code.spec.ts` from `Wiki/`.
- [x] 3.3 <!-- Non-TDD --> Run `npm exec --yes pnpm@11.8.0 -- run test:playwright` from `Wiki/` and `openspec validate improve-wiki-code-copy-interaction --strict` from the host root; inspect scoped Wiki and host diffs before any commit.

## 4. Approved icon-language refinement

- [x] 4.1 <!-- TDD --> Replace the product assertions for the former two-document glyph with 18px, 1.5px-stroke outline clipboard-and-document expectations; run the focused spec and confirm it fails before source changes.
- [x] 4.2 <!-- TDD --> Replace the inline idle SVG with the Heroicons outline clipboard-document geometry, preserving the existing line-style copied/error feedback and control behavior.
- [x] 4.3 <!-- Non-TDD --> Amend the author-facing widget documentation to describe the outline clipboard-and-document affordance.
- [x] 4.4 <!-- TDD --> Re-run the focused copy suite, Wiki checks, linting, the full browser suite, and strict OpenSpec validation; inspect scoped diffs without staging or committing unrelated work.
