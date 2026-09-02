# Canonical local/loop variable typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-14 — ordinary local declarations, `for` initializer declarations, and `foreach` variables |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixture | a function containing two comma-separated locals, a two-declarator `for` initializer, and a later incomplete statement; a successful compile fixture also executes the same declaration/scoping shape |
| Construction/sealed-AST assertion | every authored declarator exists exactly once under the exact function; later declarators can resolve earlier declarators; declaration/init statements preserve source order; `for` variables remain visible to condition/increment/body but do not escape the loop |
| Architecture assertion | Parser publishes a typed variable header and an exact-declaration initializer/finish action for each ordinary local and `for` declarator; `foreach` publishes typed variable identity without inventing default construction; statement assembly routes declaration shells only by exact source range and fails closed when the typed action is absent; no Sema source contains a semantic `case snDeclaration:` decoder |
| Expected RED | current Parser emits typed actions only for globals/fields, calls `NotifySema(node->lastChild)` for ordinary and `for` declarations, and three Sema paths rediscover only the first identifier/type/initializer from `snDeclaration` |
| Production edit allowed after RED | yes, limited to typed local/for/foreach declaration actions, exact range routing/flattening, lexical-scope preservation, and removal of declaration semantic replay |

## Locked design

Parser continues to build `snDeclaration` shells for LEGACY compilation,
recovery, and structural range routing. Canonical semantic authority instead
uses these bounded actions:

1. after each local identifier is parsed, Parser publishes the authored name,
   already-resolved canonical type, exact identifier range, and zero access
   traits to `ActOnVariableHeaderAction` under the live function-like owner;
2. after that exact declarator's optional initializer is complete, Parser
   passes only the returned DeclId plus the bounded initializer expression to
   a specifically named local-declarator action;
3. after the semicolon, Parser publishes an exact-range declaration sequence.
   Normal compound assembly flattens that sequence into the enclosing block,
   while a `for` retains it as the initializer sequence already flattened by
   the loop lexical-scope resolver;
4. `foreach` publishes its variable header and a DeclStmt without a default
   constructor/assignment, because the loop protocol supplies the element;
5. declaration-shell routing may use only node kind and exact source range to
   retrieve an already-authored statement. Missing typed actions diagnose and
   fail closed; name, type, qualifiers, initializer, and ownership are never
   reconstructed from the shell.

The action payload contains no durable Parser/Engine pointer and persists no
numeric runtime TypeId. The construction Context uses `asCQualType` only
within the same compile. Sealed identity remains stable declaration/type keys.

## Lexical-scope invariants

- A normal local declaration sequence must be flattened into its surrounding
  compound body. Leaving the synthetic sequence as a nested Block would hide
  the declared variables from following statements.
- A `for` declaration sequence remains the initializer child. The existing
  `for` resolver flattens its children into the loop scope so condition,
  increment, and body can use the variables without leaking them afterward.
- Headers are published in declarator order. In
  `int First = 1, Second = First + 1`, `First` exists before `Second`'s
  initializer expression is parsed.
- A `foreach` variable is declared in the loop scope but is not default
  constructed by the declaration action.

## Explicit exclusions

- General type spelling/qualifier/template production still enters through
  the named `ActOnQualTypeFromNode` adapter and remains a later type-action
  closure.
- Initializer expressions still enter through named expression adapters;
  this slice removes declaration-shell semantic replay, not every expression
  Parser-node adapter.
- `switch` bodies parse illegal declarations for diagnostics; this slice does
  not change the language rule.
- Full lambda/catch/source-level try semantics and cleanup-plan closure remain
  separate statement/lifetime work.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## Required evidence

1. test-only build and valid behavior/architecture RED before production;
2. Runtime/Editor build after the bounded repair;
3. exact local/`for`/`foreach` construction and sealed-AST GREEN;
4. successful execution proving comma-declarator order and loop scoping;
5. SemaAuthority, ProductionCodeGen, Parser declarations/loops/foreach GREEN;
6. source scans proving declaration-shell routing has no semantic decoder;
7. strict OpenSpec validation and parent/plugin `git diff --check HEAD`;
8. RED, root cause, invalid runners, repair, results, and non-claims copied to
   the final issue/progress/task ledgers.

## Mutation checks

The permanent tests must fail if any of these mutations is introduced:

- remove the local header action or bind all comma initializers to the first
  identifier;
- restore ordinary/`for` `NotifySema(node->lastChild)` declaration replay;
- retain a `case snDeclaration:` semantic decoder in declaration or statement
  Sema;
- leave an ordinary local sequence nested instead of flattening it;
- default-construct a `foreach` variable before the loop protocol supplies it;
- silently fall back when an exact typed declaration action is absent.

## Non-claims

- This does not complete all data-type, expression, statement, or lifetime
  typed actions.
- This does not prove detached CodeGen or TypedASTJIT language completeness.
- This does not remove LEGACY Parser syntax trees.
- This does not change executable defaults.

## TDD record

The two permanent tests were added before the production edit:

- `ParserLocalAndForDeclaratorsAreTypedIndividuallyBeforeLaterRecovery`
  proves that `First`, `Second`, `I`, and `Limit` are each authored exactly
  once under the same function DeclContext even when a later `return` is
  incomplete. It also compiles and executes the corresponding valid source
  through Canonical CodeGen and requires `Entry() == 34`.
- `ParserLocalLoopVariableFamiliesUseTypedActionsWithoutDeclarationReplay`
  is the architecture/mutation gate for typed local/`for`/`foreach` actions,
  absence of declaration replay callbacks and `case snDeclaration:`, exact
  range routing, and the fail-closed diagnostic.

The test-only build passed:

`Saved/Build/cta-local-loop-variable-red-test-build/20260827_113735_171_532e7e4c/RunMetadata.json`

The valid pre-production SemaAuthority run produced the intended **319/321
PASS, 2 FAIL** and only the two new tests failed:

`Saved/Tests/cta-local-loop-variable-red/20260827_113803_635_66c1e0d8/Report/index.json`

One earlier `RunTests.ps1 -Target ...` attempt was rejected by the wrapper
because `-TestPrefix` is mandatory. It did not launch Unreal and is invalid
runner evidence rather than a product RED.

## Implementation and discovered regressions

Parser now publishes one variable header immediately after each local or
`for` identifier, binds the exact optional initializer to the returned DeclId,
and publishes one exact-range declaration sequence after `;`. Ordinary block
assembly flattens that sequence; a `for` retains it as the initializer carrier
that the loop scope resolver already flattens. `foreach` publishes the exact
typed variable and DeclStmt without default construction. Statement routing
uses exact owner/range identity and diagnoses `local-declaration-action-missing`
instead of reconstructing semantics from the Parser shell.

The first implementation build passed:

`Saved/Build/cta-local-loop-variable-first-fix-build/20260827_114822_865_5e0fe235/RunMetadata.json`

The first complete regression was a valid product failure: **248/321 PASS,
73 FAIL** at
`Saved/Tests/cta-local-loop-variable-first-green/20260827_114848_097_6315e5fe/Report/index.json`.
The verifier consistently reported `stmt-multi-owner`. Ordinary compound
assembly had copied statements out of the synthetic declaration sequence but
left the same edges on that carrier, giving each statement two structural
parents. The repair clears the carrier children only after normal-block
flattening; the `for` initializer carrier keeps its children because it is the
actual loop initializer. The repair build passed at
`Saved/Build/cta-local-loop-variable-sequence-owner-fix-build/20260827_115014_344_6ecf72de/RunMetadata.json`.

After that repair the two focused tests were **2/2 PASS** at
`Saved/Tests/cta-local-loop-variable-focused-green/20260827_115032_450_1fdc081f/Report/index.json`,
while the complete SemaAuthority group was **320/321 PASS** at
`Saved/Tests/cta-local-loop-variable-sema-authority-green/20260827_115111_186_76ff738d/Report/index.json`.
The only failure, `ParserActOnListPatternBeforeBlockCloseFails`, exposed an
error-recovery ordering regression: the old whole-declaration callback had run
before the malformed `{1,2` initializer returned, while the new exact action
returned too early and lost the partial list-pattern expression. The repair
publishes the exact initializer action before returning the parse error. Its
build and focused recovery result are:

- `Saved/Build/cta-local-loop-variable-recovery-fix-build/20260827_115259_898_7127620e/RunMetadata.json`;
- `Saved/Tests/cta-local-loop-variable-list-recovery-green/20260827_115313_772_e1952ec0/Report/index.json`
  — **1/1 PASS**.

## Final evidence

| Gate | Result | Evidence |
|---|---:|---|
| final Runtime/Editor build | PASS | `Saved/Build/cta-local-loop-variable-execution-assert-build/20260827_115717_073_f76010b3/RunMetadata.json` |
| exact local/loop behavior + architecture | **2/2 PASS** | `Saved/Tests/cta-local-loop-variable-execution-focused-green/20260827_115738_409_6b24e5db/Report/index.json` |
| complete SemaAuthority | **321/321 PASS** | `Saved/Tests/cta-local-loop-variable-sema-authority-final-green/20260827_115815_734_72290e1d/Report/index.json` |
| complete ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-local-loop-variable-production-codegen-final-green/20260827_115907_186_7c6a8d5e/Report/index.json` |
| Parser declarations | **18/18 PASS** | `Saved/Tests/cta-local-loop-variable-parser-declarations-final-green/20260827_115947_756_696dcbf0/Report/index.json` |
| declaration replay scan | PASS | no `case snDeclaration:` remains in maintained-fork Sema sources; Parser source contains the typed local/`for`/`foreach` actions and fail-closed diagnostic |
| strict OpenSpec validation | PASS | `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` |
| parent/plugin diff checks | PASS | both `git diff --check` exit 0; existing LF/CRLF conversion notices only |

One final build command incorrectly used unsupported `-RunId`; the wrapper
forwarded it to UBT, which rejected the nonexistent target before compilation.
Its metadata is
`Saved/Build/build/20260827_115701_240_0acf91a5/RunMetadata.json` and it is not
product evidence. A read-only `rg` command also had malformed PowerShell
quoting and was immediately reissued correctly; it changed no state.

## Outcome

CTA-S-14 is resolved for ordinary local declarations, `for` initializer
declarations, and `foreach` declaration identity. The maintained-fork Sema
sources no longer contain any semantic `case snDeclaration:` decoder.

Tasks `4.2`, `4.3`, `4.4`, `4.5`, and `13.2` remain unchecked because general
type/property/default/funcdef/lambda/body/expression/statement/lifetime action
closure and Builder/LEGACY authority retirement are still open. The compiler
default remains LEGACY and Cache V2 remains default-disabled.
