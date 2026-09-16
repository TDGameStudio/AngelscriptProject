---
replan_id: replan-20260915-083349-single-generator-dump
status: applied
source: user
source_ref: current-session-one-generator-one-as-and-formatting-clarification
scope: one complete formatted source dump per generator instead of per-case files
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: cc20502da78a2af56f8ecd293342319b94658cb9b0e227cfdfb9317b6833bfda
result_tasks_sha256: b8634a4f49766638d7d112ab12ff25fd7bf58dce0bfb0820c4af3c2984f992e1
created_at: 2026-09-15T08:33:49.933742+00:00
resume_task: '1.1'
---

# Single product dump replan

## Trigger and Evidence

The user corrected the export requirement: one generator should produce one .as file containing all cases because per-case files are too numerous. They explicitly emphasized readable generator-owned formatting. The preceding export plan had per-case files and JSON sidecars, which is now invalid.

## Decision

Add BuildDumpSource to each concrete generator. It emits a product header, all aggregate entries with shared helpers, and separately labeled reject modules. The product test writes one GeneratedCases/<ClassWithoutF>.as next to the current Unreal.log. No per-case files, per-product export folders or index.json. Generators own Allman/tab/LF layout; the test helper writes exact text.

## Impact

Every product adds the dump API and complete-section/layout tests. Task 1.1's helper now has ResolveOutputFile and WriteDump. One GeneratesAndExportsAllCases test per generator remains, with VerifiesCompleteCorpus as the separate acceptance test.

## Old Task Disposition

All 123 pending tasks are preserved. No completed tasks existed. The preceding applied replans remain immutable history; their per-case export instructions are superseded by this record and the current design.

## Diff Snapshot

- Before: parent Change directory untracked; no plugin implementation edited.
- Task ~: all 122 dump signatures, case 7/8 expectations, helper contract and final acceptance artifact wording.
- Edges: unchanged; exact 123-node graph equality checked before writes.
- Artifacts ~: proposal, spec delta, design, tasks, source-export precedence, glossary, thirteen catalogs, inventory and planning evidence.
- Attachments +: this applied record and one decision talk, indexed once.

## Preserved Work

All 122 products and 36,686 cells, PascalCase names, descriptor APIs, canonical single-case APIs, physical C++ ownership, one test per generator and source-only verification remain. The complete dump is diagnostic output, not a replacement executable module for mixed rejection cases.

## References and Result

Resume task 1.1 after validation. Full product dumps are produced when the implementation's unit tests run; this planning update does not generate or execute AS.
