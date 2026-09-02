# Canonical call-argument provenance static review — 2026-08-30

## Verdict

No reachable CANONICAL Stage 3 path was found that traverses
`asCScriptNode` expression/statement structure or invokes `asCCompiler`.
The remaining call boundary is narrower: Sema owns lookup, overload choice,
argument arrangement and conversion, but does not yet publish the argument's
exact formal identity and origin as first-class AST facts. CodeGen therefore
authenticates types against Canonical declarations while still reconstructing
formal pairing from parallel positions.

This is a reachable semantic-authority gap, not evidence of a LEGACY fallback.
It should be fixed before default cutover because same-typed reordered/default/
hidden arguments can otherwise preserve arity and ABI shape while losing the
sealed source meaning.

## Reviewed production path

```text
Parser asSCallExprAction (source-order expression + optional copied name)
  -> asCSema::ActOnCallExpr
  -> ArrangeCallArguments
       named/default/hidden rewrite and forward-formal array
  -> ConvertCallArgumentsToFormalTypes
  -> asCSema::ActOnCall
       reverse children into CallExpr
  -> Seal / publication verifier
  -> asCBytecodeCodeGen::EmitCall
       child index -> sealed parameter index -> Runtime parameter index
```

Evidence reviewed:

- `as_sema.h`: the Parser action is pointer-free and explicitly delegates
  arrangement/conversion to Sema;
- `as_sema_expr.cpp`: named/default/hidden provenance is currently placed in
  presentation literals while the arranged formal array is reordered;
- `as_sema.cpp`: `ActOnCall()` reverses only expression IDs into children;
- `as_ast_verifier.cpp`: publication checks exact callee and dispatch but has
  no complete argument/formal invariant;
- `as_bytecode_codegen.cpp::EmitCall()`: sealed and Runtime formal selection
  is still calculated as `count - 1 - childIndex`;
- `as_ast_sidecar.cpp`: V8 serializes no argument-origin/formal records;
- existing SemaAuthority tests cover diagnostic/default/named/hidden shape,
  while ProductionCodeGen has no direct default/named/hidden ABI cluster.

## Classification

| Finding | Classification | Action |
|---|---|---|
| Sema and CodeGen do not traverse native expression/statement nodes | already correct | preserve with static/focused gates |
| native Parser retains `asCScriptNode` | allowed syntax/LEGACY/reference | no removal in this OpenSpec |
| named/default/hidden provenance exists mainly in `literal` text | reachable blocker for complete semantic authority | CTA-S72 structured facts |
| CodeGen pairs formals by position | reachable blocker for mechanical backend consumption | exact formal record + verifier + emitter use |
| Runtime signature shell still originates from native declaration projection | correct but adjacent separate boundary | record as CTA-S72B; do not silently expand current RED |
| Public AST V1 lacks call-argument records | separately scoped ABI decision | keep V1 unchanged |
| Sidecar V8 cannot reconstruct provenance | reachable persistence loss | append-only V9 bump after RED |
| Standalone would consume shared maintained-fork sources | explicitly deferred adaptation/gate | no Standalone-specific edit or verification claim |

## Recommended sequence

1. authenticate the missing internal record/API with a compile RED;
2. expose only the minimum context mutation needed by Sema, Sidecar and tests;
3. authenticate source-built Sema facts plus forged verifier and round-trip
   failures in one focused RED cluster;
4. populate records before reversal, update them after conversions, and handle
   deferred calls with the same path;
5. verify formal-slot uniqueness/completeness and origin/name/source
   invariants; direct calls require exact ParamDecl IDs while indirect funcdef
   calls use an authenticated formal ordinal because their resolved callable
   variable/parameter does not own invocation ParamDecls;
6. make CodeGen use record `formal` identities and treat Runtime arrays only
   as ABI-compatible generation-local projections;
7. run focused and broad gates once, then evaluate CTA-S72B separately.

The detailed gate, fixtures, non-claims and required evidence are recorded in
`attachments/canonical-call-argument-provenance-gate-2026-08-30.md`.

## Implementation discovery: named arguments were ranked before binding

The first production hidden-middle fixture found an additional reachable
Sema-authority defect. `ResolveCallee()` called `FindBestCallee()` before
`ArrangeCallArguments()`, but passed only expression IDs. A call such as
`NativePack(C: 3, A: 1)` against `[A, Hidden, C]` was ranked as source-order
`[A, Hidden]`; the non-default `C` formal then appeared missing. This is why a
trailing hidden default worked while a hidden formal between two named
formals failed with `unresolved-callee`.

The correction must not speculatively call the mutating arrangement pass for
every overload candidate. Candidate exploration now uses a pure formal-slot
plan that knows names, hidden/default omissions and receiver shape. A focused
`2/2` execution gate proves both named/default and hidden-middle calls after
this root correction. The selected-callee arrangement path still has to emit
that same plan as first-class `asSASTCallArgument` records; positional child
reconstruction remains a blocker until verifier, Sidecar and CodeGen consume
the records.

## Implementation review checkpoint: records exist, consumers remain split

The subsequent read-only verifier/CodeGen audit confirmed that the current WIP
does populate direct call records in Sema, but publication verification and
`EmitCall()` still reconstruct formal meaning from child positions. The safe
boundary is therefore:

- keep structural `Seal()` permissive enough for deliberately forged test
  graphs;
- authenticate exact formal coverage, uniqueness, order, origin and receiver
  shape only in `asCASTVerifyPublication()`, before any CodeGen mutation;
- make CodeGen obtain source semantics from `callArguments` while preserving
  the existing reverse-formal VM stack order, receiver push, hidden return
  pointer and lambda-capture suffix;
- do not treat ordinary method receivers, hidden return pointers or lambda
  captures as source formal records; a mixin receiver is the formal-zero
  exception.

The audit also identified two explicit blind spots that must not be hidden by
positional reconstruction:

1. indirect funcdef calls resolve through `VAR`/`PARAM`, which does not own the
   invocation `ParamDecl` list even though the Runtime funcdef type exposes a
   signature;
2. constructor calls are converted from `CALL` to `CONSTRUCT`, and the current
   `ActOnConstruct()` representation does not carry call-argument provenance.

The focused SemaAuthority checkpoint authenticated the first blind spot in
practice: `425/436 PASS`, with six funcdef/lambda failures reporting the
missing callable-plan route, four stale presentation assertions still reading
mutated literals, and one real receiver-to-free-function lookup regression.
Evidence:
`Saved/Tests/cta-s72-sema-provenance-focused/20260830_031928_324_9216c66f`.
Neither blind spot is permission to fail open at publication. Indirect
funcdefs need a shared pointer-free Canonical callable-signature view;
construct provenance should remain an explicit follow-up boundary unless a
required CTA-S72 execution fixture proves it must be included now.

## Implementation review checkpoint: Sema and publication verifier closed

The main-thread implementation and independent read-only audit converged on
the same minimal indirect-call design. `ResolveCallee()` was already producing
the correct `VAR`/`PARAM + FUNCDEF` callee and indirect dispatch; the missing
authority lived only in source-argument-to-formal planning. The shared helper
now produces a pure value view containing optional exact `formal`, mandatory
Canonical `formalType`, formal name and formal index. If a Canonical funcdef
declaration is unavailable, `asCFuncdefType::funcdef` is used only transiently
and each Runtime parameter is immediately normalized through
`FromScriptParameterABI()`. No Runtime pointer is stored and no synthetic
`ParamDecl` is invented.

The same helper now serves overload ranking and final arrangement, eliminating
ranking/arrangement drift. Receiver removal is limited to actual method/mixin
candidates, so member syntax cannot make a same-named free function appear
arity-compatible. Diagnostic dump output projects the structured records and
does not restore literal-based semantics.

Evidence:

- complete Editor build: `171/171`,
  `Saved/Build/cta-s72-callable-formal-view-build/20260830_033035_394_89126c0e`;
- complete SemaAuthority cluster: `436/436`,
  `Saved/Tests/cta-s72-callable-formal-view-focused/20260830_033308_524_d5592ac6`.

Publication verification was deliberately added only to
`asCASTVerifyPublication()`. This preserves forged graph construction and
ordinary `Seal()` diagnostics while preventing CodeGen from consuming a call
whose records disagree with reverse-formal children, direct ParamDecl identity
or canonical formal type, or duplicate a formal ordinal. Indirect records are
required to keep `formal` invalid and use their captured ordinal/type identity.

The verifier risk cluster moved from the authenticated `51/53` RED to
`53/53 PASS`:

- RED: `Saved/Tests/cta-s72-call-argument-verifier-red/20260830_033411_029_a5f35816`;
- GREEN: `Saved/Tests/cta-s72-call-argument-verifier-green2/20260830_033708_606_2087e275`.

The remaining reachable blocker is no longer Sema or publication validity.
`asCBytecodeCodeGen::EmitCall()` must consume the authenticated record identity
while preserving current reverse-formal ABI push order, and Sidecar V9 must
round-trip all record fields. Constructor provenance remains explicitly
separate unless a required current fixture demonstrates that CTA-S72 must
cover it.

The verifier closure is relation-complete for records that exist, but not yet
coverage-complete: empty or partial `callArguments` for a direct callee with
non-zero formals still needs a permanent CodeGen/publication RED. The CodeGen
step must add that gate and fail before mutation; it must not preserve a
positional fallback merely to accept incomplete older graphs.

## Disposition — 2026-08-30

The implementation has closed the review findings for the CTA-S72 scope.
Publication verification now rejects empty/partial coverage and impossible
origin/name/source-ordinal combinations, CodeGen consumes the authenticated
records mechanically, and Sidecar V9 round-trips the pointer-free facts with
identity coverage and a V8 safe-miss boundary.

Final non-Standalone evidence is recorded in
`../attachments/canonical-call-argument-provenance-gate-2026-08-30.md`:

- Compiler CanonicalAST: `634/634 PASS`;
- Frontend CanonicalAST: `181/181 PASS`;
- Cache: `584/584 PASS`.

This disposition does not rewrite the historical audit checkpoints above and
does not claim constructor provenance, Standalone adaptation, complete call-
family coverage, product-default CANONICAL selection or aggregate OpenSpec
completion.
