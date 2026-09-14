# Planning and implementation validation

Date: 2026-09-13. Scope: planning, implementation and specification synchronization for `angelscript/feature-test-code-database`.

## Preflight

- Coverage: eight durable requirements map to the producing/proving tasks in tasks.md, plus one documentation/closure task.
- Placeholder scan: passed for all task cards; no prohibited unresolved-template phrases remain.
- Symbols: discussed and planning-assumed public names are distinguished in drafts/glossary.md; tasks identify producing dependencies. Resource helpers and fixtures are future outputs, not existing verified APIs.

## Creation validation

Passed checks in this creation turn:

- Harness openspec.validate with arguments `angelscript/feature-test-code-database --type change --strict --json`: 1 passed, 0 failed, no issues.
- Harness task.status: valid nine-node DAG, 0 complete, 9 remaining; root task 1.1 is dependency-ready, not execution-authorized.
- Harness harness.evolution.status for this exact Change: TaskPlanValid=true and StructuralErrors empty. ClosureReady=false is expected because implementation is unexecuted; this is not an archive/terminal check.
- Exact attachment audit using Harness Get-HarnessAttachmentIndexCount: all six attachment files indexed once, excluding INDEX itself.
- Local Markdown link closure, English-only maintained record text and absence of ignored-draft dependencies: passed.
- Old unified-framework Change file SHA-256 inventory compared equal to its pre-edit snapshot, including its pre-existing dirty files.

Executed commands used the imported Harness module and selected workspace context in the current PowerShell process. The focused supplemental audit read files and reused the Harness attachment-count helper; it did not mutate any product code or execute a broad Harness suite.

## Implementation proof

- Source ownership and normalization: fresh build `8ddd1aa7803c46aaacab0059e30227ad`; focused Automation `c7a08dd8f88a41f197ceefa63d2ee8b5`, 4/4 passed.
- Builder and value lifetime: fresh build `b3ae5b80f56d4b12ae7c27a7555afc66`; focused Automation `b3b7e58b32ab4edba981ade348336c79`, 5/5 passed.
- Container and inline annotation parsing: fresh build `e8b82ead5029491c9cc1bbe9eae4fb71`; focused Automation `a559a818b6c744ffbea49cbea77901d5`, 5/5 passed.
- Database admission and queries: fresh build `cba2688263d9441c9b65f0b1fe9664ad`; focused Automation `47d0054d6afc431b8e579e2eed42a614`, 5/5 passed.
- Deferred static registration: fresh build `4fd97f6627df46c895f584ccf71685c6`; focused Automation `6f064434a3db4a70a8b3f1e87c9d16e8`, 4/4 passed.
- Windows resource generation and exact payload inventory: the retained eight-build/seven-test incremental sequence is `Saved/Harness/TestCodeResource/20260913-151314-d06acebe79954acfaadd77f989d089f9/Evidence.json`. It proves edit/add/rename/delete/no-op behavior, expected conflict failure without artifact mutation, and canonical restoration.
- Embedded resource admission: fresh build `fd3f130d778d4bd19a02e5562fbb26c9`; focused Resources Automation `eda5b214f9284021997b4c01818156e7`, 4/4 passed; adjacent Registration Automation `5c26c278f8054bd390ec729c93b17ac9`, 4/4 passed.
- Cross-module adoption: fresh build `4724f769c961424b98c28574abea0f36`; focused Automation `a530b8b37a0f4aadac0802ad8d91a8ed`, 4/4 passed. It proves the shared center identity, resource and static providers, version reads, clean registration state and replacement-only compile gates.
- Final shared-path snapshot: bounded aggregate Automation run `0c2ac31ae4414dd79b7e36863702d16d` passed all 32/32 `Angelscript.UnitTest.Framework` tests with zero warnings, errors, failures, skips, not-run or in-process cases. It used the final successful editor binary from build `4724f769c961424b98c28574abea0f36`; only Skill/OpenSpec Markdown changed afterward. This supersets the earlier Source, Builder, Parser, Database, Registration, Resources and Adoption selectors after the common admission path reached its final form.

Each behavioral group first observed a bounded RED failure after a fresh build; exact RED run IDs and failure reasons remain on the owning Task Cards. Quick, Performance, Integration and the full plugin suite were intentionally omitted because the focused selectors plus resource-incremental driver cover the demonstrated surface without script execution or the dormant legacy runtime.

## Specification synchronization

- The current capability identity `angelscript/testing/code-database` was created through Harness `openspec.spec create`, run `702e9cb9ee49433bacd719d9098e00c5`; read-back run `8df0136c0d8d4c8083e725666910646e` confirmed the generated manifest and an initially absent `spec.md`.
- The Change delta adds eight new requirements. Because no current behavior existed at this identity, synchronization copies each complete Requirement and Scenario Card into the current spec and removes the delta-operation heading. No existing requirement or scenario is overwritten.
- The maintained AngelScript test Skill now routes shared fixture authors and consumers to an English provider/query guide. The guide documents only behavior exercised by the completed tasks.
- The focused guide audit passed all ten content anchors and its Skill link closure. Strict Change validation run `54f8abc6de754ee08f7e01c65906286f` and strict capability validation run `3ec1e947ad474da4a84808b0e31ec4ca` each passed 1/1 with no issues.

## Proof limits

The database is a source-material layer: it does not compile or execute AngelScript, run reload sequences, issue LSP/debugger requests, or define expected-diagnostic verdicts. Generic annotations and topics do not imply those consumer protocols. The resource transport is currently Windows-specific; static C++ providers and the public database model do not expose resource IDs. Markdown/OpenSpec validation proves record structure only; runtime behavior is supported by the fresh Harness build, Automation and incremental-driver evidence above.

## Authorization

The user requested immediate creation after confirming the name; this overrode further conversational approval pauses for record creation without retrospectively turning empty form replies into accepted options. The user subsequently requested completion of this exact Change, authorizing implementation while leaving the explicit planning assumptions intact.

## Evidence-gated implementation replan

During task 3.1 preflight, local UE 5.8 source showed that `RulesAssembly` compiles module rule files and targets but does not compile an arbitrary adjacent helper `.cs`. The planned standalone `TestCodeResourceGenerator.cs` therefore could not execute. The integration detail was revised without changing resource behavior: the generator is private to `AngelscriptTest.Build.cs`, a stable module-owned `.rc` wrapper includes generated Intermediate entries, and an intentionally absent external-dependency sentinel forces rule re-evaluation so add, rename and delete inventory changes are observed. Later RC proof showed that `UEBuildBinary::CompileResourceFiles` does not add the default resource when a custom RC exists, so the generated entries explicitly include `Default.rc2`; resetting the stable wrapper's public `FileItem` metadata cache lets that same UBT invocation observe a changed wrapper timestamp. This evidence changes task files and private build mechanics only; no public name or user-owned design decision changed.

Task 3.2 preflight also showed that the existing public C++ factory returns exactly one built file, while one owner DLL resource index must be rejected or admitted atomically as a multi-file batch. Direct admission before `ActivateRegistrations` would mark the database activated and skip ordinary factories. The task therefore adds a registry-private multi-file provider record that joins the existing activation snapshot and produces one detached owner batch. This requires focused modifications to the catalog/registration implementation files but leaves the public registration constructor and every query signature unchanged.
