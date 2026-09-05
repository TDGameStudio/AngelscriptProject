---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-023432-ubt-duplicate-source-basename
status: resolved
source: verification
source_ref: run-8d50869f797a421ebf421d793298f080
affected_tasks: ["1.1"]
created_at: 2026-09-05T02:34:32+08:00
resolved_at: 2026-09-05T02:36:51+08:00
resolution_ref: run-079f0c1fe393414e83067c9bf8b8e1d5
---

# UBT rejects duplicate C++ source basenames within one module

## Symptom

The first GREEN build after adding the new frontend source model stopped before compilation. Unreal Build Tool reported that the preserved production `source/as_source_manager.cpp` and new `source/frontend/as_source_manager.cpp` conflict because non-Unity intermediate outputs would use the same filename.

## Investigation Log

1. RED run `d0c43c28bcf94934980039daa4cb6ec3` failed at the intended missing frontend header.
2. The planned frontend header and implementation files were added without changing current production routing.
3. Run `8d50869f797a421ebf421d793298f080` invalidated the makefile because a source directory was added, then UBT enumerated both manager implementation units and rejected their duplicate basename.
4. The diagnostic occurs in UBT's module input planning before C++ compilation; it is not a C++ symbol collision and is not caused by Harness path projection.

## Root Cause

Task `1.1` assumed that a distinct subdirectory was sufficient to distinguish a new `.cpp` file. UBT requires unique C++ input basenames within the module for non-Unity intermediate object naming.

## Disposition

An applied Replan preserves the public `frontend/as_source_manager.h` name and the old production source, but renames only the new implementation unit to `as_frontend_source_manager.cpp`. Build `8d3971ef5122438d8409aca77938eda1` and exact-prefix test `079f0c1fe393414e83067c9bf8b8e1d5` resolve the issue.

## Evidence

### Failure Evidence (RED)

- Managed run: `8d50869f797a421ebf421d793298f080`.
- Log: `Saved/Harness/Unreal/Runs/8d50869f797a421ebf421d793298f080/Command.log`.
- UBT result: `Input filename conflicts` followed by both physical source paths and `Result: Failed (OtherCompilationError)`.

### Resolution Evidence (GREEN)

- Managed build: `8d3971ef5122438d8409aca77938eda1`, 7/7 actions and exit 0.
- Exact Fast test: `079f0c1fe393414e83067c9bf8b8e1d5`, 4/4 SourceDiagnostics scenarios passed.

### What This Proves

- New and legacy `.cpp` files in one UE module need distinct basenames even when their directories differ.
- Preserving old production source while creating an isolated frontend requires a unique implementation-unit name.

### What This Does Not Prove

- It does not require changing public class or header names.
- It does not justify deleting or modifying the existing production source manager.
- It does not indicate a Harness execution or reporting defect.

## Links

- `attachments/replans/replan-20260905-023432-unique-source-manager-implementation.md`.
- `tasks.md`, Task `1.1`.
