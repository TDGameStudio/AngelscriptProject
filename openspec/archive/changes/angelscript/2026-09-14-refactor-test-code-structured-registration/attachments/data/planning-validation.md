# Planning validation

Date: 2026-09-14

## Requirement and acceptance coverage

- `Checked material construction` is owned by Tasks 1.1, 2.1 and 4.2: negative language is admitted, descriptor structure is validated, and batch isolation is observed through compiled activation.
- `Checked-in generated original file delivery` is owned by Tasks 1.1, 1.2, 3.1 and 3.2: the protocol is parsed before mutation, structured v2 rendering is byte-readable, and check/generate migration is synchronized.
- `Conforming independent fixture protocol parsers` is owned by Task 4.1, including positive products, negative stable codes/locations and the prose-order boundary.
- Exact query order, one FileMeta truth and cross-module handwritten registration are owned by Task 4.2.
- Every success criterion and forbidden path in `attachments/drafts/handoff.md` maps to at least one task case or a plan-wide constraint.

Result: complete coverage; no accepted behavior is left only in an attachment.

## Placeholder scan

Reviewed `proposal.md`, `specs/**/spec.md`, `design.md` and `tasks.md` for unfilled template markers, generic task-card instructions and unresolved alternatives. None remain. The inter-Change prerequisite is an explicit lifecycle boundary, not a placeholder implementation step.

Result: clean.

## Symbol consistency

- Change ID: `angelscript/refactor-test-code-structured-registration`.
- Public C++ input: `FAngelscriptTestSourceDescriptor` with nested `FPoint`, `FBreakpoint`, `FRange`, `FOriginSpan` and `FAnnotations`.
- Existing Builder methods gain three-argument overloads; `FAngelscriptTestSource::FromGeneratedData` is not produced.
- Python IR uses `ParsedFile`, `ParsedVersion`, `ParsedAnnotations`, typed parsed annotation records, `OriginSpan`, `CodegenDiagnostic` and `parse_source_file` consistently in producing/consuming tasks.
- Generated registration form is `GRegistration_<encoded FileTag>` under `AngelscriptTest::Generated`; Counter is `GRegistration_Language_Counter`.
- Generator signature is format v2 while authored fixture Version remains v1.

Result: consistent with `design.md` and `attachments/drafts/glossary.md`; no public name is left for planning-time invention.

## Tooling proof

- `openspec.validate angelscript/refactor-test-code-structured-registration --strict --json`: passed one Change with zero issues.
- Harness `task.status`: parsed all seven tasks, reported zero graph issues and derived Tasks 1.1 and 2.1 as Ready.
- Harness `harness.evolution.status`: reported a valid TaskPlan with no structural errors; terminal closure is intentionally unavailable because implementation and workflow evaluation have not started.
- Attachment index audit: all nine non-index attachment files are linked exactly once from `attachments/INDEX.md`; the index is 34 lines.

Result: the Change is decision-complete and implementation-ready after the separately owned `angelscript/refactor-testing-unified-framework` replan prerequisite is satisfied.
