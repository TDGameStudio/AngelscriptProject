---
replan_id: replan-20260915-090619-generate-test-layout
status: applied
source: user
source_ref: current-session-frameworktests-generate-directory-and-forloop-test-rename
scope: generator test TUs and export helper under FrameworkTests/Generate
base_commit: acb127e8539638b0a2ff6392b894d976a81b5bdb
base_tasks_sha256: b8634a4f49766638d7d112ab12ff25fd7bf58dce0bfb0820c4af3c2984f992e1
result_tasks_sha256: 2b609779621893c405f233bebfe6e8aa396ab57c6441011135caa23852e14dff
created_at: 2026-09-15T09:06:19Z
resume_task: '1.1'
---

# Generator test layout replan

## Trigger and Evidence

The user asked to replan FrameworkTests placement: generator tests should live under `FrameworkTests/Generate/`, matching `Framework/Generate/`, and the existing ForLoop TU `GenerateTests.cpp` should receive a product-specific name.

## Decision

All 122 product tests, the corpus test and `FGeneratedCaseExport` move to `FrameworkTests/Generate/`. ForLoop's file is `ForLoopGeneratorTests.cpp`. `GenerateTests.cpp` is deleted. Checked-in gold stays under `FrameworkTests/Gold/`. Automation prefixes are unchanged; ForLoop remains `Angelscript.UnitTest.Framework.ForLoopGenerator`.

## Impact

Task 1.1 Files now create the export helper and ForLoop test under `Generate/` and delete the generic TU. Every later product Files tree uses `FrameworkTests/Generate/<ClassWithoutF>Tests.cpp`. Include path for the helper becomes `FrameworkTests/Generate/GeneratedCaseExport.h`. No Task ID, DAG edge, cell count or proving command change.

## Old Task Disposition

All 123 tasks remain pending and unchecked. Task 1.1 is still the resume node and still owns the shared descriptor and export contract. In-progress 1.1 implementation at the old FrameworkTests root is not completion evidence; apply must place files at the new paths.

## Diff Snapshot

- Before: parent Change directory untracked; 1.1 implementation existed at the old test paths and is not part of this planning edit.
- Task ~: 123 Files trees for test TUs and the export helper; 1.1 adds an explicit delete of `GenerateTests.cpp`.
- Edges: unchanged.
- Artifacts ~: proposal, design, glossary, inventory, thirteen product catalogs, planning-validation and INDEX.
- Attachments +: this applied record and one decision talk, indexed once.

## Preserved Work

All 122 products, 36,686 cells, PascalCase names, descriptors, dump contract, gold locations and source-only verification remain. The in-progress ForLoop generator and RED/GREEN work stay usable after the test TU is moved and renamed.

## References and Result

Resume task 1.1 after validation. This planning update does not move implementation files or run UE tests.
