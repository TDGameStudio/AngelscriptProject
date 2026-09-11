# Migration baseline: active AngelScript plans

Captured 2026-09-11 17:55 before syntax migration (task 3.1), from the plan text: root `- [ ] X.Y` / `- [x] X.Y` lines. Strict validation on the packaged 0.10.0 fails all seven with `unsupported-task-format`; the 17 spec files failing strict on four-space clause detail are pre-existing baseline outside this Change.

| Plan | Old format | Tasks | Done IDs | Graph keys |
|---|---|---|---|---|
| `angelscript/feature-delegates-ue-interop` | inline | 10 (`1.1 1.2 1.3 2.1 2.2 2.3 3.1 3.2 3.3 4.1`) | none | 10 |
| `angelscript/feature-frontend-diagnostics-tooling` | inline | 9 (`1.1 1.2 2.1 2.2 3.1 3.2 3.3 4.1 5.1`) | none | 9 |
| `angelscript/feature-memory-gc-observability` | inline | 1 (`1.1`) | none | 1 |
| `angelscript/refactor-bindings-two-stage-pipeline` | root-checkbox list | 24 (`0.1 1.1 1.2 2.1 2.2 2.3 2.4 3.1 3.2 3.3 3.4 3.5 4.1 4.2 5.1 5.2 5.3 5.4 5.5 5.6 6.1 6.2 6.3 6.4`) | none | 24 |
| `angelscript/refactor-defaults-constructor-unification` | inline | 1 (`1.1`) | none | 1 |
| `angelscript/refactor-sdk-drop-native-gc` | root-checkbox list | 3 (`1.1 2.1 3.1`) | none | 3 |
| `angelscript/refactor-testing-unified-framework` | inline | 16 (`1.1 2.1 2.2 2.3 2.4 3.1 3.2 3.3 4.1 4.2 5.1 5.2 6.1 6.2 7.1 7.2`) | none | 16 |

## After migration

Captured 2026-09-11 18:00 on the packaged `openspec 0.10.0` after the syntax-only migration. ID sets and done sets equal the baseline above; every plan has at least one Ready node.

| Plan | Strict validate (issues) | Tasks | Done | Ready | CJK / draft refs |
|---|---|---|---|---|---|
| `angelscript/feature-delegates-ue-interop` | Succeeded (0 tasks.md / 0 total) | 10 | none | `1.1` | 0 / 0 |
| `angelscript/feature-frontend-diagnostics-tooling` | Failed (0 tasks.md / 124 total) | 9 | none | `1.1` | 0 / 0 |
| `angelscript/feature-memory-gc-observability` | Succeeded (0 tasks.md / 0 total) | 1 | none | `1.1` | 0 / 0 |
| `angelscript/refactor-bindings-two-stage-pipeline` | Succeeded (0 tasks.md / 0 total) | 24 | none | `0.1` | 0 / 0 |
| `angelscript/refactor-defaults-constructor-unification` | Succeeded (0 tasks.md / 0 total) | 1 | none | `1.1` | 0 / 0 |
| `angelscript/refactor-sdk-drop-native-gc` | Succeeded (0 tasks.md / 0 total) | 3 | none | `1.1` | 0 / 0 |
| `angelscript/refactor-testing-unified-framework` | Failed (0 tasks.md / 16 total) | 16 | none | `1.1 2.1 2.2` | 0 / 0 |

The two `Failed` results carry zero `tasks.md` issues: all remaining issues are the pre-existing four-space clause-detail failures in those Changes' untouched `specs/**/spec.md` files (diagnostics 124, testing-unified 16), the same debt class recorded above for 17 spec files. They belong to the owning Changes, not to this migration.

## Deviations from verbatim carryover

- `refactor-testing-unified-framework` 1.1: the three `.agents/skills/angelscript-test-guide/cqtest*` entries, one of which had a CJK file name, were folded into the glob `cqtest*.md` so the plan stays English. The directory itself does not exist in the workspace (the current Skill is `angelscript-test`); paths were kept and marked `+`, flagged for the owning Change.
- `feature-delegates-ue-interop` 4.1: its verification was prose, carried verbatim into a fence; it is not executable and is a content item for the owning Change.
- Plans whose proposals had no `#` title took the title and Goal from `change.yaml`. Generic Harness policy paragraphs (Import-Module snippets, build-before-Automation, enforced report, shared-run rules) were dropped in favour of the `execution-conventions.md` link; every plan-specific constraint was kept as a bullet.
- `refactor-bindings-two-stage-pipeline`: the coverage table expanded `5.1 through 5.6` to explicit IDs and added one row mapping the SDK prerequisite to `0.1`.
