# Verification and preservation

## Scope and result

This is a parent guidance/test-helper and AS planning change. All three outcome tasks have their required implementation and focused verification. No AS source, UE operation, Git staging/commit/push or workspace operation occurred. Lifecycle terminal evaluation and archive are separate final actions after this evidence is indexed.

## Commands actually run

Ordinary Harness commands ran in the selected workspace's current PowerShell 7 process.

| Check | Actual result |
|---|---|
| & ./.agents/skills/harness/tests/Protocol.Tests.ps1 | PASS after executable exact-index RED/GREEN; final rerun passed |
| & ./.agents/skills/harness/tests/HarnessCutover.Tests.ps1 | PASS; thin single entry and existing routing boundaries retained |
| & ./.agents/skills/harness/tests/HarnessEvolution.Tests.ps1 | PASS, including isolated terminal-policy fixtures |
| & ./.agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths $guidanceSurfacePaths | PASS; exact stable path array is in tasks.md |
| Same OpenSpecSkill script with SurfacePaths selecting the two affected active Change directories | Initially rejected three unindexed pre-existing AS diagram source companions; after indexing those existing files, PASS |
| python C:/Users/scottmei/.codex/skills/.system/skill-creator/scripts/quick_validate.py <skill-directory> | PASS for harness, test-driven-development, openspec, openspec-apply-change, openspec-continue-change and openspec-verify-change |
| git diff --check -- <owned guidance/record paths> | Exit 0; Git only reports existing LF-to-CRLF normalization notices |

The stable guidance selection includes AGENTS.md, Harness, TDD, OpenSpec, apply/continue/verify Skills, the project workflow, and harness/core. Only actual repository-content audit inputs are bounded; package safety, protocol/authoring/link assertions and all hermetic fixtures always run. The closing Change ID is absent from reusable test defaults.

### Strict deterministic operations

Each command below used Invoke-Harness with the named command and ArgumentList.

| Command and arguments | Run ID | Result |
|---|---|---|
| openspec.validate angelscript/refactor-builder-engine-independent --strict --json | 2a81e5f013074bb2a26fae4a33851720 | valid, zero issues |
| openspec.validate harness/refactor-task-planning-batched-tdd --strict --json | 9c281eaad75446b18902807452a9d8e9 | valid, zero issues before final evidence bookkeeping |
| openspec.validate --specs --strict --json | 568a94df3c70455893595ab336556540 | 15/15 current specs pass |
| openspec.workflow validate angelscript --json | f93c91346c904ff1939f0fa1e1ab2f38 | valid, zero issues |
| openspec.doctor --json | 2d9d34be8b674c56a6130be96b519e6b | valid, zero errors; 3 active / 36 archived before closure |
| task.status, Change angelscript/refactor-builder-engine-independent | aa394baa0ba34726b9f64570da8623c7 | 8/17 complete, 9 pending, sole Ready 4.2 |

## Real RED/GREEN and consumer evidence

Protocol baseline falsely counted a valid historical knowledge entry twice because a prose promotion path shared its suffix. New positive/negative fixtures failed before the exact-entry helper fix. Whole-path bullet/code/link/table entries now count, while prose/suffix mentions do not. Missing and genuine duplicate entries still fail. Active implementation-issue indexing uses the same corrected helper. No archive was edited.

OpenSpecSkill default initially failed on two unrelated English violations. Explicit-selection fixtures observed 13 failing branches before the selection fix; the subsequent complete-owner closure fixtures observed six failing branches before the owner-selection fix. Positive/negative controls cover selected bad content, full-scan bad neighbors, child-to-whole-index closure, parent-to-descendant ownership, missing/empty/outside/drive-relative/reparse inputs and overlap deduplication. The test-only SurfacePaths argument supersedes the unshipped language-only attempt retained in the two immutable Harness replans.

The separate real AS content selection then reported three existing JSON diagram companions absent from INDEX. Only their INDEX entries were added; generated files were preserved. This ordinary artifact repair required neither a Review nor another planning change.

Ordinary evolution preparation then exposed a format mismatch: general attachment audits accept bare path bullets, but the current terminal helper recognizes only backtick-wrapped path bullets. Both owned active INDEX files now use that existing terminal-compatible format. No executor change or broadened archive policy was introduced; final exact terminal verification is still required.

The fixed independent before/after exercise and six policy hashes are in data/behavior-probe.md. The old consumer already preserved authorization/code/proof honesty, but split a related parser policy into four tasks. The new consumer uses one policy task and one independent exporter, with concrete cases and group-level proving. This is bounded prompt-behavior evidence, not universal agent reliability or C++ test evidence. Six policy hashes were rechecked unchanged after the exercise.

### Owner script identities

- Protocol.Tests.ps1 SHA-256: 82FBBF29AB92B0D1DC6BAB61DFFA717987B02A2E00C024748176D07CB633CC0C.
- OpenSpecSkill.Tests.ps1 SHA-256: FB135158C9FD50023265A277D2197E09D4B22BA00765D6F9637A78B21368D320.

## Unchanged full-scan failures

The default OpenSpecSkill command is deliberately NOT reported green. Its existing English findings remain:
- openspec/changes/angelscript/refactor-testing-unified-framework/tasks.md:75.
- openspec/specs/angelscript/language/frontend/preprocessing/knowledges/clang-directive-and-source-backquery.md:18.

The intermediate language-only attempt reached eight unrelated knowledge-index Markdown-link violations, named in the indexed scope issue. No filename exemption or unrelated content fix was introduced. Resolving the scope issue means explicit bounded proof works; it does not mean repository-wide content compliance.

## Durable synchronization and AS handoff

The harness/core delta was semantically merged into the two owning requirements (Ready-to-execute Task authoring and Impact-scoped verification by default). Existing clause-owned details and all 25 unrelated requirement bodies were preserved. Focused knowledge is held by the existing task-authoring, verification and TDD owners; no new knowledge file or Documents copy is needed.

AS original 13 node identities and eight completed nodes are preserved. Four pending feature outcomes are added: 4.2 custom access, 4.3 destination-aware conversions, 4.4 frozen-host callable input, 4.5 lambda execution-context permissions. Original 4.1 remains integrated acceptance; downstream 5.2/6.1/7.1/7.2 stay pending. Actual old 4.1 predecessors were 2.2, 2.3, 3.2 and 3.3; the applied replan's compact Diff Snapshot abbreviates that list without 2.3, while its exact task digests and portable TaskPlan preserve the authoritative transformation. All four predecessor nodes remain complete.

AS task file result SHA-256: E8FA76A3E2541976F0B6AD07A59853CBE663E8BD2318F4030B823C52C764DD38. The graph was checked before writing and confirmed by portable task.status afterward. Current design replaces delayed-first-run defaults only for subsequent work, preserving the prior explicit exception as history. Current WIP is not certified by the preceding 481/481 report. Both AS material issues remain open; conversion implementation now belongs to 4.3.

## Preservation witness

Before and after guidance work, 2,428 tracked/nonignored plugin paths produced the same digest:
6140EF666E9FCD7774505EBC9C744115CF0B482A6B1C791475FB33446A02D28F.

Algorithm: collect git ls-files --cached --others --exclude-standard in Plugins/Angelscript, Sort-Object -Unique, form each relative path plus a space plus the uppercase SHA-256 (or MISSING), join with LF, and SHA-256 the UTF-8 bytes. This proves this turn preserved plugin contents, not that its unverified WIP compiles. Existing unrelated parent changes, prior deletions, generated artifacts and dirty submodules remain untouched.

## Intentional omissions

No Test-Harness Quick, Performance or Integration profile; no Unreal build, Automation/Baseline/NativeEngine launch, full suite, Standalone or plugin/C++ test. This change affects guidance, record authoring and static owner contracts, not product execution, performance or a release boundary. Existing AS raw reports were read only to correct historical coverage claims.

No automatic Review was created. The separate stale UE project-context issue remains explicitly open; fixing it or finishing AS belongs to subsequent in-scope work, not this guidance closure.
