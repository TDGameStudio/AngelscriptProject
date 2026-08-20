# Attachments

This directory records discussion and code-path notes for
`refactor-as-primary-engine-typed-ast-generate`. Normative requirements stay in
`../design.md`, `../specs/`, and `../tasks.md`. Attachments explain why those
files say what they say; they do not override them.

| File | What it captures |
|---|---|
| `scheme-overview.md` | Matching vs non-matching Generate, optional HIR, Dev/Shipping vs Cook |
| `collect-binds-and-native-form-catalog.md` | `bCollectStaticJITCompatibilityBinds` today; why a catalog; how the table is filled |
| `bytecodejit-native-form-and-headers.md` | How BytecodeJIT already emits native calls and `#include`s |
| `bind-replay-vs-cached-bind-snapshot.md` | Why bind lambdas still replay per Engine; BindDB vs catalog vs a future bind-surface snapshot |

When a later finding changes direction, update `design.md` / specs / tasks first, then mark the superseded paragraph here rather than deleting the file.
