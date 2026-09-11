# Review of `angelscript/feature-delegates-ue-interop/tasks.md` against the settled card contract

Reviewed 2026-09-11. 10 tasks, 183 lines, retired inline format (`— verify:` / `> Files:`), created 2026-09-05 as a "creation-only feature record" with no `design.md`.

## What is already good

- Every product card has the same skeleton: Consume/Produce sentence (outcome + handoff), Cases paragraph, three ordered steps (RED / implement / GREEN), Files, one `ue.test` prefix. That is the right set of information.
- Cases are concrete in substance: literal values appear (`AddOne(41)` returns 42, `Offset=10` → `Execute(5)` = 15, health `(100,75)`, "60 supported names", "31 deferred spellings").
- The acceptance-mapping table at the end is exactly the "spec coverage" self-review the new contract wants at the top.
- Glob exclusions are explained in prose as the contract asks.

## What is wrong or missing

1. **Symbols were never settled.** Task 1.1 is "complete the design … specify actual public/internal interface names and types for binding expressions, explicit receiver/payload state, generation leases, native-event views and reflected descriptors". Every later card says "consume 1.1's contract" and names nothing beyond `asCCallableTypeDecl`, `CreateCallableType`, `CreateCallableSignature` (borrowed from another Change). Test class names are "planned additions" — only prefixes exist. So the plan is not executable by a zero-context implementer: all naming is deferred into the first task. Root cause: the Change was created at proposal stage (09-05) before the brainstorming naming gate existed (09-11); design was pushed into a task instead of preceding the Change.
2. **Cases are one dense paragraph per card** — 8 to 12 cases in a single sentence chain. Each is a literal case, but there is no input / expected / role column, and the "60 forms" and "31 spellings" have no named oracle file. Under the new contract these become a table (or a pointer to an indexed `attachments/data/*.md` inventory for the 60/31 matrices).
3. **Preamble is 45 lines and four sections** (authorization boundary, language-surface prerequisite, proving setup, TDD paragraph). Two of them repeat Harness policy; only the language-surface prerequisite and the cross-Change dependency are plan-specific and belong in a `Global constraints` header.
4. **4.1's verification is prose**, not a command: "Actual editor and cooked fixture runs both report…". Invalid under both the old and new machine contract; its exact `ue.*` route was also deferred to 1.1.
5. **Files rely on `*`/`**` globs over frontend directories** (`as_expr*`, `as_ast_*`, `DelegateAdapters/**`). Acceptable only with the exclusion prose that is present, but roles (Create/Modify/Test) are absent — the new `Create:/Modify:/Test:` prefixes fix this.
6. **Format**: retired inline metadata → Ready = 0; it cannot run through Harness at all today.

## What to add when migrating this plan

- A header: Goal (one sentence), Architecture (link to a design that must exist first), Global constraints (the language-surface prerequisite and the `refactor-vm-symbolic-execution` / `refactor-language-surface-ue-focused` dependencies), Requirement coverage table (move the acceptance mapping up).
- Per card: a one-paragraph brief under the heading; `**Interfaces**` with the actual new names (callable representation type, payload/receiver state type, generation lease type, native-event view type, reflected descriptor type, and each test class `F…Tests`) with their source (glossary / naming round); `**Cases**` as a table; `**Files**` with roles; `**Verification**` command for 4.1.
- Remove task 1.1 as a task; the design it describes is `design.md`, produced by `openspec-continue-change` after a brainstorming naming round settles the symbols. A plan whose first task is "finish the design" is not Ready-to-execute.

## Answer to "does the grill phase ask about symbols?"

Yes, since 2026-09-11: `brainstorming/references/naming.md` makes every new public type, module, file and key function a grill question with recommendation, alternatives and evidence; settled names go to the draft `glossary.md`, the design's "Vocabulary and Naming" section, and each task's interfaces block. `openspec/references/tasks.md` fails the authoring preflight for a task that creates a public name without listing it. This Change predates the gate, which is why its symbols are deferred to task 1.1.
