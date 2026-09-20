# Planning Validation

Captured on 2026-09-13 for angelscript/refactor-builder-source-entry. This is record/plan verification only; no product task has executed.

## Coverage

The Requirement coverage section in tasks.md maps both capability deltas and every accepted input, ownership, callback, declaration, and transfer condition to seven permanent DAG nodes. Six behavior nodes define 37 named cases; the remaining node synchronizes the two affected specs. Source/index migration and the maintained Builder entry share one node because removing the caller-built snapshot requires adapting that complete input path and its consumers together.

The cases distinguish source pointer identity from byte equality; empty body from unprepared input; per-input FileID from durable identity; published declarations from successful executable output; ordinary hook failure from all-object final notification; and source retention from dependency ownership.

## Placeholder and symbol checks

The plan was manually checked for required header/card sections, ordered labels, concrete named cases, new RED coverage, one proving command per node, and no prefilled execution Evidence. The placeholder scan and final attachment/link checks passed with zero issues.

Public source, Builder, callback, and transfer names come from the exported glossary. bGenerateDebugObservations follows the inspected asSBuilderOptions option convention and implements the already accepted opt-in observation decision. Future test classes and their CaseName methods follow the NativeEngine CQTest identity convention; they are not claimed to exist already.

Consumed source paths were inspected. In particular the existing projection class is FAngelscriptDescriptorConsumer in frontend/Compile/as_descriptor_consumer.h, not a newly named descriptor consumer. No new descriptor family is planned. Fine-grained result access remains recursively read-only even where neighboring Get-style methods must evolve.

## Baseline of affected current specifications

Both current specs were checked before future synchronization:

| Capability | Exact Harness run | Existing issues | Disposition |
|---|---|---|---|
| angelscript/language/frontend/builder | 014a42673191414383207f77d84d599d | 2 indentation diagnostics, first at line 39 in Analyze supported source through the replacement | Task 4.1 repairs only clause-detail formatting, retaining unrelated semantics. |
| angelscript/language/frontend/source-diagnostics | 77cebfc78f774b83bdc6bf588a71f987 | 29 indentation diagnostics, first at line 13 in A valid range selects original bytes | Task 4.1 repairs only clause-detail formatting, retaining unrelated semantics. |

The exact command form was Invoke-Harness openspec.validate with the capability ID, --type spec --strict --json. These failures predate this Change. Neither current specification has been edited during planning. A valid new delta does not silently repair unspecified existing scenarios.

## Record validation

The seeded-export validation initially reported only the expected missing required proposal/tasks artifacts. After planning, strict Change validation passed with zero issues. Task status run da1535f2075c49beb2918790bd588990 parsed seven nodes, zero complete, with only 1.1 Ready.

A scoped Harness attachment audit uses the existing Get-ExactAttachmentIndexEntryCount and Test-AttachmentIndexCompatibility definitions from .agents/skills/harness/tests/Protocol.Tests.ps1, extracted through the PowerShell AST without executing the full protocol suite. The seeded export passed; the final audit includes this record.

Final strict Change validation run f4063a4064f940e3991fe184e4fb7376 passed with zero issues. Task status run 821131031beb4d8f890319741c20a1d2 reports seven tasks, zero complete, and only 1.1 Ready. The scoped Harness attachment audit, English-prose scan, local Markdown-link closure check, forbidden-placeholder scan, and consumed-file existence/producing-task check all passed with zero issues. The case-header scan found all 37 named cases. Ready is derived planning status, not implementation authorization.

## Scope and omitted execution

No C++, UE build, Automation test, spec synchronization, archive, commit, or submodule edit ran. Planned C++ proving commands require a successful Harness build beforehand. The broader NativeEngine selector in 2.1 is justified by shared source/index and fixture migration; other behavior nodes use exact class prefixes. Quick, Performance, Integration, the full Harness protocol suite, and legacy tests were omitted because this turn changes only scoped planning records.

The confirmed knowledge note remains candidate. Inspection of UE string/view implementation is not evidence that the planned product migration has passed.
