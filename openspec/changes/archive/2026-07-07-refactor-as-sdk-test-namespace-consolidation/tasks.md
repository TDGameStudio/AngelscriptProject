# Tasks: refactor-as-sdk-test-namespace-consolidation

## 1. Audit current engineering state

- [x] 1.1 Inspect current `AngelScriptSDK/` source inventory and compare it with the historical OpenSpec audit.
- [x] 1.2 Check for source-level `ASSDK` naming residue and `AngelscriptTest_*_Private` namespace residue.
- [x] 1.3 Identify behavior-coverage tasks that do not belong to the namespace/helper consolidation scope.
- [x] 1.4 Record current verification status without reusing stale pass counts as fresh evidence.

## 2. Re-scope this OpenSpec

- [x] 2.1 Rewrite `proposal.md` so the change covers structural SDK helper, namespace, and naming cleanup.
- [x] 2.2 Rewrite `design.md` to document the raw SDK bare-engine boundary and behavior-coverage follow-up split.
- [x] 2.3 Rewrite the `as-native-sdk-test-coverage` delta so it no longer requires this refactor to complete all high-priority SDK runtime behavior coverage.
- [x] 2.4 Add `current-state-audit.md` with current counts, completed structural evidence, remaining gaps, and deferred follow-up candidates.
- [x] 2.5 Mark the older `sdk-test-audit.md` as a historical snapshot rather than the current inventory.

## 3. Closeable structural outcome

- [x] 3.1 Treat helper consolidation, `_Private` namespace removal, and SDK naming convergence as the completed scope of this change record.
- [x] 3.2 Move object/OOP/runtime/string/atomic/thread behavior coverage gaps to follow-up candidates instead of unchecked tasks in this change.
- [x] 3.3 Keep commit/archive decisions separate from behavior coverage expansion.

## Follow-up candidates

These are intentionally not checkbox tasks for this change. They should become one or more dedicated future OpenSpec changes.

- `test-as-sdk-behavior-coverage`: execute or document-exception the remaining compile-only object, OOP, type, conversion, and runtime cases.
- `fix-as-sdk-string-runtime-tests`: resolve the `RegisterStringFactory` 2.33 versus 2.38 API gap and re-enable `AngelscriptStringUtilTests.cpp`.
- `fix-as-sdk-thread-atomic-linkage`: expose or otherwise test `asCAtomic` and `asCThreadManager` without disabled `#if 0` files.
- `test-as-sdk-runtime-control`: decide whether true suspend/resume, abort, callbacks, and Thiscall execution belong in raw SDK tests or a higher runtime layer.
- `docs-as-sdk-terminology-cleanup`: replace remaining prose-only `ASSDK/raw SDK` wording where project docs now prefer `SDK` or `native SDK`.

## Verification note

No fresh clean `Angelscript.TestModule.AngelScriptSDK` pass is claimed by this record cleanup. A later archive decision may run:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label sdk-namespace-consolidation-archive -TimeoutMs 1200000
```
