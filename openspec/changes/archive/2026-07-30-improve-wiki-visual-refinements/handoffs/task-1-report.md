# Task 1 report: browser regression coverage

## Result

Implemented the requested red browser-regression coverage without changing CSS.

## Changed paths

- `Wiki/wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts`
- `openspec/changes/improve-wiki-visual-refinements/handoffs/task-1-report.md`

## Required red verification

Ran from `Wiki/`:

```powershell
npm exec --yes pnpm@11.8.0 -- exec playwright test wiki/tiddlers/tests/playwright/angelscript-theme.spec.ts --grep "resize rail|More sidebar|SDK description"
```

Exit code: `1` (9.7 s). The three failures are expected CSS assertions:

- Idle resize rail opacity was `0.14`, expected `0`.
- More-sidebar category buttons included `1px` right borders, expected all `0px`.
- SDK description-to-tag spacing was `26.390625px`, expected at most `12px`.

No fixture or selector failure occurred: the More selected/focused assertions and the SDK frame, element, and order assertions completed before their red CSS assertions.

## Concern

The exact outer `npm exec` command emitted warnings that `--grep` was parsed as an npm argument and consequently ran all nine spec tests; the six pre-existing tests passed. The Playwright web server did not hang or block the run.
