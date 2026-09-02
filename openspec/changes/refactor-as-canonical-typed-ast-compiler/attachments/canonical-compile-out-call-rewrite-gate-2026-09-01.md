# Canonical compile-out call rewrite gate (CTA-S174)

## Scope and decision

CTA-S174 ports the deleted `TypedSemanticIR/CallRewrites` oracle for ordinary
call expressions onto the retained Canonical AST. The three registration-time
dispositions are now authored by Sema and consumed from a sealed, pointer-free
shape:

- `CompileOutEntirely` seals a typed `void` `CallRewrite` with no executable
  child;
- `ReplaceWithFirstParam` seals only the selected first-formal value plus exact
  formal/source provenance;
- `CompileOutAsMethodChain` seals only the effective receiver plus explicit
  implicit-receiver provenance.

The backend does not inspect a live `asCScriptFunction::compileOutType`. It
lowers only the final Canonical expression. Discarded authored operands are not
resolved, diagnosed, evaluated, or retained as dangling semantic nodes.

This closes the compile-out blocker found by the Task 5.3 historical-oracle
audit. Task 5.3 remains open until CTA-S175 proves exact import
bind/rebind/unbind snapshot immutability and the final call-family audit is
rerun.

## Canonical representation

The public append-only model gains:

- expression kind `asAST_EXPR_CALL_REWRITE`;
- declaration traits `asAST_TRAIT_COMPILE_OUT_ENTIRELY`,
  `asAST_TRAIT_REPLACE_WITH_FIRST_PARAM`, and
  `asAST_TRAIT_COMPILE_OUT_AS_METHOD_CHAIN`;
- stable literal discriminators `compile-out-entirely`,
  `compile-out-first-param`, and `compile-out-method-chain`.

Sema projects the registration input onto the resolved callable declaration.
All same-name candidates must agree on the disposition, matching the maintained
LEGACY compiler's pre-argument-compilation contract. The verifier then requires
exactly one trait, the corresponding literal, no call dispatch or safe point,
and one of the three exact edge/type/value-category shapes.

`ReplaceWithFirstParam` retains one `asSASTCallArgument` with exact formal
declaration, formal ordinal `0`, authored source ordinal, positional/named
origin, authored name rules, and the formal type. Method-chain retains one
receiver argument with no formal/source ordinal and
`asAST_CALL_ARGUMENT_IMPLICIT_RECEIVER` origin.

## Discarded-subtree protocol

Compile-out happens before normal overload argument compilation. Canonical
Parser/Sema may nevertheless already have appended provisional expression
nodes for the authored syntax. Arena allocation is append-only, so Sema cannot
erase those nodes.

`asCASTContext::TombstoneDiscardedExpr` converts a discarded root into an inert,
edge-free `Error` node. `asCSema::DiscardSemanticSubtree` removes only
diagnostics and deferred-call/decl-ref work whose source ranges are wholly
owned by the discarded argument, tombstones their roots, and finally tombstones
the argument root itself. Retained operands keep their normal diagnostics and
deferred obligations. Whole-snapshot verification therefore remains strict
without making discarded operands semantically observable.

## CodeGen and Sidecar

Canonical Bytecode CodeGen lowers:

- the entirely-erased form to no bytecode;
- the first-param and method-chain forms by lowering their single retained
  child, including lvalue-address and object-type propagation where required.

The Sidecar schema advances from V11 to V12. V12 admits `CallRewrite` and its
retained `CallArgument` relation. A dedicated round-trip test constructs all
three shapes, seals them, encodes/decodes them, verifies traits and provenance,
and requires byte-exact re-encoding.

The first complete Cache-prefix attempt exposed that the UE Cache wrapper still
published schema `11` while the maintained fork required `12`. Production
capture consequently failed closed with `asAST_SIDECAR_UNKNOWN_KIND`. The
wrapper constant and its version comment are now synchronized to V12. The old
ExactWarm detached-enum negative fixture then returned to its intended semantic
rejection path.

## TDD and verification evidence

Authentic RED:

- `Saved/Tests/cta-sema-call-53-compile-out-red2/`
  `20260901_151101_794_2e7a6ed9`: the three discarded unresolved identifiers
  were diagnosed because Canonical Sema had no compile-out rewrite.
- `Saved/Tests/cta-sema-call-53-compile-out-green1/`
  `20260901_153158_251_58e10d81`: the initial rewrite exposed a dangling
  unreachable DeclRef, proving that merely dropping the owning edge was not a
  valid whole-snapshot solution.
- `Saved/Tests/cta-sema-call-53-compile-out-green2/`
  `20260901_153821_400_9b91cc68`: deferred-root tombstoning alone still missed
  an argument-root DeclRef; the final root tombstone closed it.

Green gates:

- root-tombstone build: `Saved/Build/`
  `cta-sema-call-53-compile-out-root-tombstone/`
  `20260901_154044_888_7f5bd9a1`, PASS;
- exact Sema + CodeGen after root tombstone:
  `Saved/Tests/cta-sema-call-53-compile-out-root-tombstone/`
  `20260901_154104_033_18d14038`, **2/2 PASS**;
- Sidecar V12 build: `Saved/Build/`
  `cta-sema-call-53-compile-out-sidecar-v12/`
  `20260901_154506_958_2a8e9c2c`, PASS;
- exact Sema + CodeGen + Sidecar:
  `Saved/Tests/cta-sema-call-53-compile-out-sidecar-v12/`
  `20260901_154533_713_0f22c2b8`, **3/3 PASS**;
- complete SemaAuthority + ProductionCodeGen:
  `Saved/Tests/cta-sema-call-53-compile-out-full/`
  `20260901_154644_125_4793471f`, **760/760 PASS**, zero failures/skips;
- V12 wrapper synchronization build:
  `Saved/Build/cta-sema-call-53-compile-out-cache-v12-sync/`
  `20260901_160427_689_1535dfb8`, PASS;
- formerly failing ExactWarm fixture:
  `Saved/Tests/cta-sema-call-53-cache-v12-sync-focused/`
  `20260901_160529_886_8565e2c5`, **1/1 PASS**;
- exact Sema + CodeGen + Sidecar after wrapper synchronization:
  `Saved/Tests/cta-sema-call-53-compile-out-v12-sync-exact/`
  `20260901_160628_618_f06411cc`, **3/3 PASS**.

- post-schema-guard build:
  `Saved/Build/cta-sema-call-53-compile-out-schema-guard/`
  `20260901_161823_410_fcf87787`, PASS;
- complete Cache V12 prefix:
  `Saved/Tests/cta-sema-call-53-compile-out-cache-full-v12-sync-20m/`
  `20260901_161845_558_ff4efab4`, **586/586 PASS**, zero
  failures/skips. The earlier 10-minute attempt completed 347 tests with zero
  failures before the runner terminated it; the 20-minute rerun completed in
  1,036,731 ms;
- complete Frontend CanonicalAST prefix:
  `Saved/Tests/cta-sema-call-53-compile-out-frontend-full/`
  `20260901_163611_064_86070975`, **189/189 PASS**, zero
  failures/skips.

## Non-claims

This gate covers the historical ordinary-call compile-out oracle. Other
`compileOutType` uses in copy construction, destruction, and specialized
operator/lifecycle paths remain owned by their expression/lifetime tasks unless
already covered by a separate gate. CTA-S174 does not complete Task 5.3 by
itself, does not close native ABI/bridge Task 7.4, and does not authorize default
CANONICAL cutover or LEGACY deletion.
