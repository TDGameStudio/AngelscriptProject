## Why

The Wiki's code-block copy button is always visually present and its hand-drawn glyph is not immediately recognizable as a copy action. Readers need a quieter code surface that still keeps copy discoverable on touch devices and clearly returns to a repeatable idle state after every copy attempt.

## What Changes

- Replace the idle glyph with a compact, line-style clipboard-and-document icon rendered inline without a new icon dependency.
- Hide the idle control on desktop fine-pointer devices until its code block is hovered or keyboard-focused; keep it low-emphasis but visible on touch and no-hover devices.
- Make copy feedback explicitly temporary and latest-attempt-wins so repeat clicks remain available and older asynchronous results cannot overwrite newer feedback.
- Document the code-block copy presentation and add desktop, keyboard, touch, and repeat-copy Playwright coverage.

## Capabilities

### New Capabilities

- `wiki-code-copy-interaction`: Defines the visual affordance, accessible states, adaptive visibility, and repeat-copy feedback contract shared by ordinary and AngelScript code blocks.

### Modified Capabilities

None.

## Impact

- Wiki submodule: `src/angelscript-tools/codeblock-copy.ts`, `src/angelscript-tools/index.css`, its author documentation, and the existing product Playwright suite.
- Host repository: this OpenSpec record only.
- No WikiText attributes, public TypeScript exports, plugin dependencies, clipboard transport, or content data model change.
