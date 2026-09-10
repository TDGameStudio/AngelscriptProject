# Creator ownership replan validation

Planning checks only: no SDK/Runtime implementation, UE build, Automation, GC stress test or benchmark was run. All product tasks remain unchecked.

| Change | Strict validation run | Tasks | Complete | Resume |
| --- | --- | --- | --- | --- |
| angelscript/feature-types-external-ownership | `959410f3c729430c9f740f28fedb3a0a` | 13 | 0 | 1.1 |
| angelscript/refactor-bindings-two-stage-pipeline | `f1501494ed044212be8273443c0b6e88` | 24 | 0 | 0.1 |

Candidate frontmatter and task ID/check states exactly matched their before versions before application. All 37 task proving commands had one direct Verification command, a Files section and zero PowerShell syntax errors. Canonical task.status and strict Change validation passed after application. The binding entry still requires completed SDK implementation and a verified handoff.

Both current tasks.md hashes match their applied replan result hashes. Every unowned file in the two Change directories, including historical reviews/replans/assessments, retained its before hash. Parent and plugin tracked diff digests are unchanged. No current specification or product source was edited. Both attachment indexes were checked for one link per local attachment, valid targets and the 120-line bound.

New future acceptance includes creator-owned dynamic metadata, repeat Register stability, host withdrawal InUse for Engine/dependency uses, both acquire/withdraw and attach/withdraw race orderings, one AddRef/Release per successful acquired result, Builder-to-Engine transfer, host preparation retention, and separate A/B two-instance GC cycles sharing one host TypeInfo. Metadata itself is reclaimed through owner references, not registered as a script GC object. Existing numeric concurrency, exhaustion, no-reuse and final regression groups remain unchanged.

Public API decisions now use Registry.Register/Unregister and existing MetadataImage plus AddRef-owned outputs. Public publication/registration-handle and custom query-lease class requirements are removed; older indexed artifacts preserve superseded API shapes as history.
