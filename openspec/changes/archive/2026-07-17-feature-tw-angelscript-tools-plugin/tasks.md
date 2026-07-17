## 1. Test-first widget contract

- [x] 1.1 <!-- TDD --> Add `AngelscriptCodeWidget.tid` with a representative AngelScript example and a focused Playwright spec for tokens, title, line numbers, and copy state.
- [x] 1.2 <!-- TDD --> Run the focused Playwright spec and confirm it fails because the `as-code` widget is not registered yet.

## 2. Browser tokenizer and widget

- [x] 2.1 <!-- TDD --> Add `Wiki/src/angelscript-tools/highlighter.ts` with escaped HTML output and conservative semantic tokenization.
- [x] 2.2 <!-- TDD --> Add the TiddlyWiki plugin entry, metadata, and `AsCodeWidget` implementation with title, line numbers, copy action, and refresh lifecycle.
- [x] 2.3 <!-- TDD --> Add the light documentation-card CSS and make the focused Playwright spec pass.

## 3. Documentation and verification

- [x] 3.1 <!-- Non-TDD --> Add bilingual plugin readme content and a short example entry to the plugin tree.
- [x] 3.2 <!-- TDD --> Run `pnpm run check` from `Wiki/`.
- [x] 3.3 <!-- TDD --> Run `pnpm run lint` from `Wiki/`.
- [x] 3.4 <!-- TDD --> Run `pnpm run build` from `Wiki/`.
- [x] 3.5 <!-- TDD --> Run `pnpm run test:playwright` from `Wiki/`.
