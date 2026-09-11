# Glossary

Settled in Round 4 (2026-09-11 17:08, form answers all A) unless noted.

| Name | Kind | Meaning |
|---|---|---|
| `harness/refactor-task-cards-heading-nodes` | Change ID | The single Change: CLI parser + release, authoring contract, migration of the 7 active plans. |
| heading node | term (Round 2) | A task node written as `## [ ] X.Y Title` / `## [x] X.Y Title`; its body is everything until the next `##`, unindented. |
| brief | term (Round 2) | The first paragraph under a heading node: one-paragraph description of the task. |
| `**Outcome**` | card label | Included behavior and explicit exclusions. Mandatory. |
| `**Interfaces**` | card label | Consumed and produced symbols with signatures in code fences; every new public name with its source. Mandatory when the task produces or consumes any symbol. Replaces `Context and interfaces`. |
| `**Cases**` | card label | Literal table: input / expected / role (new RED, existing control, boundary). Mandatory for behavior tasks. |
| `**Files**` | card label (machine) | A ```` ```diff ```` fence read by the parser. Mandatory. |
| `**Verification**` | card label (machine) | One fenced proving command. Mandatory. |
| `**Notes**` | card label | Optional implementation hints, ordering, risks. Replaces `Implementation`. |
| `**Evidence**` | card label | Appended after execution only. |
| diff Files fence | term (Round 2/3) | Lines: `+ path` create, `  path` (space) modify, `- path` delete; directory lines end with `/` and prefix the indented lines below; ` # ` starts a comment; flat full paths allowed. |
| `files[]` | node JSON field | Unchanged: plain paths in Files order. |
| `file_roles[]` | node JSON field (new) | `[{ path, role: "create" \| "modify" \| "delete" }]`. |
| `unsupported-task-format` | issue code (reused) | Emitted for the retired root-checkbox list format and the older inline format, with a message naming the heading-node form. |
| `## Goal`, `## Architecture`, `## Global constraints`, `## File map`, `## Requirement coverage` | plan header sections | Fixed header after the frontmatter; `File map` optional. |
| `execution-conventions.md` | new reference | `.agents/skills/harness/references/execution-conventions.md`: Harness import, build-before-test, PASS criteria, shared-run rules; plans link it instead of repeating it. |
| `planning-validation.md` | attachment convention | `attachments/data/planning-validation.md`: record of the three-item self-review (requirement coverage, placeholder scan, cross-task symbol consistency). |
| CLI `0.10.0` | version | Release carrying the parser change. |
