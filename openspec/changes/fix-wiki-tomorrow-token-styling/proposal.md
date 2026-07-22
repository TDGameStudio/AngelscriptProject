## Why

The migrated Tomorrow Light stylesheet retained several colors but omitted the reference Wiki's normal-weight reset. Highlight.js defaults therefore made keywords and function titles bold. Several semantic roles were also collapsed into the orange group, and the AngelScript grammar treated `if (` as a function call while giving UE reflection macros the same scope as preprocessor directives.

## What Changes

- Restore the reference Wiki's complete Tomorrow Light role mapping and normal semantic-token weight.
- Distinguish UE reflection macros, preprocessors, class declarations, built-in calls, control-flow keywords, ordinary function names, types, symbols, operators, and format-string substitutions with standard Highlight.js scopes.
- Protect the intended colors and weights with browser-computed-style regression coverage.

## Capabilities

### Modified Capabilities

- `tw-angelscript-tools`: make the shared Highlight.js pipeline preserve the reference Wiki's semantic Tomorrow Light colors without incidental bold text.

## Impact

- Wiki submodule: the AngelScript Highlight.js grammar, theme stylesheet, plugin documentation/version, and Playwright code-presentation coverage.
- No author syntax, stored tiddler data, or runtime plugin selection changes.
