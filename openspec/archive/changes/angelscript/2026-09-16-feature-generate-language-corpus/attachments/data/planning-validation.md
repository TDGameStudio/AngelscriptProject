# Planning validation

## Requirement coverage

The task plan contains one independently bounded node for each of 122 catalog products and one dependent corpus acceptance node. The initial card sum is 36,686. All products are in implementation scope, including the existing ForLoop baseline. The complete set, separate rejection/fault handling, deterministic owned source and observation boundaries map to the plan's requirement-coverage section.

## Placeholder scan

The plan is generated from exact catalog identities, counts, source references and named single-case methods. No generic placeholder implementation task substitutes for a product. Product-specific source/oracle derivation is implementation work bounded by the cited source and catalog; a requirement contradiction requires a replan.

## Symbol consistency

Classes and typed builders match the accepted short-name catalog. Common method signatures match the existing ForLoop convention. Reject-bearing products own their reject interfaces. New test identities derive from the Framework CQTest convention; ForLoop keeps its existing identity. Product-specific enum/parameter field spellings follow the documented naming convention and actual axis tokens.

## Verification scope

Creation runs strict OpenSpec validation, Task DAG inspection, catalog/task coverage, local-link and attachment-index audits. No plugin implementation has changed and no C++/UE or generated-AS test is claimed. The new durable capability has no current spec baseline to synchronize yet; its delta will be promoted only after implementation verification. Heavy UE suites, builds and performance tests are intentionally omitted during document-only creation.

## Observed creation checks (2026-09-15)

- Harness `openspec.validate angelscript/feature-generate-language-corpus --type change --strict --json`: passed; one Change, zero issues.
- Harness `task.status` for this exact Change: ready; 123 tasks, zero completed, 122 product tasks ready; final task depends on all 122 products.
- `pwsh -NoProfile -File .agents/skills/openspec/tests/OpenSpecSkill.Tests.ps1 -SurfacePaths openspec/changes/angelscript/feature-generate-language-corpus`: passed, including the scoped attachment-index and authoring audit. The first attempt detected duplicated path spellings in link labels; labels were corrected and the same check passed.
- Local read-only catalog/preflight audit: 122 unique products and classes, 36,686 cells, exactly one owning task per product, 25 attachments each indexed once, all local links resolving, English Change output and required task labels/cases present. Every declared category sum matches its product total.
- Catalog totals: 28,689 normal-return targets, 5,999 compile-reject targets and 1,998 runtime-fault targets. Seven source card headers grouped fault counts; their explicit observation sections supplied the preserved detailed classification. These totals are source-generation targets, not execution evidence.

## Case-enumeration replan preflight

All 122 product nodes now declare ListCases and BuildCaseSource and have two additional new-RED cases covering source/descriptor consistency and owned typed observations. Task 1.1 owns the shared value types and header; all 121 other products depend on it. Task 14.1 tests consumer dispatch and complete canonical source addressing. The in-memory graph was checked for exact node coverage and cycles before writes. Earlier creation-check results describe the pre-replan snapshot; the amended plan requires fresh structural verification. No C++ tests ran during this planning update.

## Naming and full-export replan preflight

Exactly 122 product proving commands target GeneratesAndExportsAllCases, with a single VerifiesCompleteCorpus acceptance command. Named task Cases are assertion scenarios within those methods. All 123 task IDs and descriptor dependencies are preserved. Task 1.1 owns the exporter and existing ForLoop gold migration; per-product paths are exact in Files. Complete exports are runtime artifacts, not additional tracked corpus or gold files. The prior replan passed strict OpenSpec validation before this amendment; final combined checks follow.

## Single-dump replan preflight

The latest user requirement supersedes per-case artifact wording above: every product exposes BuildDumpSource and writes one complete formatted .as. All 122 signatures and one-method selectors are present; task graph and 123 IDs are unchanged. Generator-owned formatting, mixed rejection boundaries, full case-section membership and write-before-assert behavior are explicit. Historical validation applies only to its named snapshot; final combined checks follow.

## Final combined replan validation

- Strict Harness OpenSpec validation of this exact Change passed with zero issues after the descriptor, naming and single-dump amendments.
- The scoped OpenSpecSkill.Tests.ps1 run passed package, authoring and attachment-index checks.
- Harness task.status reports 123 pending tasks, zero completed and only task 1.1 ready; its shared metadata/export support unblocks the remaining product tasks.
- Read-only consistency checks passed: exactly 122 ListCases, BuildCaseSource and BuildDumpSource task signatures; 122 GeneratesAndExportsAllCases selectors; one VerifiesCompleteCorpus selector; every attachment indexed once; all local Markdown links resolve.
- C++ implementation, actual export files and generated-AS execution are not claimed. These amendments change planning records only; no UE build or Automation run was needed for this document validation.

## Generate-test-layout replan preflight

User-directed 2026-09-15: all generator test TUs, the corpus test and FGeneratedCaseExport move under FrameworkTests/Generate/; ForLoop's TU is ForLoopGeneratorTests.cpp and GenerateTests.cpp is deleted. Gold stays under FrameworkTests/Gold/. Task IDs, DAG edges, proving prefixes and product counts are unchanged. Resume remains 1.1. This section records the planning amendment only.
