## Verification snapshot

Verified on 2026-07-23 from the main workspace checkout against `Experiment/RefWiki/wiki/tiddlers/$__plugins_tiddlywiki_highlight_styles.tid` and the supplied `Wiki/wiki/原来配色字体配置.jpg`.

- Initial focused Playwright contract — expected RED: keyword computed to weight `700` instead of `400`.
- Focused RefWiki Tomorrow contract after implementation — PASS (`1/1`).
- `npx playwright test wiki/tiddlers/tests/playwright/angelscript-code.spec.ts` — PASS (`9/9`).
- `npm run lint` — PASS.
- `npm run check` — PASS.
- `npm test` — PASS (`1/1` plugin spec).
- `npm run build` — PASS (nine selected runtime plugins).
- `npm run test:playwright` — PASS (`20/20`).

The running Wiki reported Fira Code VF for every sampled token. Computed style sampling confirmed regular weight `400` for macros, preprocessors, keywords, class/function titles, types, attributes, numbers, strings, symbols, operators, substitutions, and comments. Representative colors were `#3e999f` (UE macro), `#a3685a` (preprocessor), `#eab700` (class title), `#4271ae` (function title), `#8959a8` (keyword/type), `#f5871f` (attribute/number/symbol), `#718c00` (string), `#8e908c` (comment), and `#4d4d4c` (operator/substitution). The operator retained the reference opacity of `0.7`.
