# CTA-S54: Canonical pointer-free parse-action identity gate

Date: 2026-08-29

Status: implemented and verified for the non-Standalone Runtime/Editor scope.

## Scope and decision

CTA-S47 removed the last native-node text/range/scope walkers from Canonical
Sema, but `as_sema.h/.cpp` still retained raw `asCScriptNode*` values in
build-local maps that associated an already-created Canonical `DeclId`,
`ExprId`, or `QualType` with Parser/Builder work. That residual did not decode
syntax children or reconstruct semantics, but it still coupled Sema lifetime
and identity to the native Parser arena.

CTA-S54 replaces that bridge with one copied value:

```text
asSParseActionIdentity = section + nodeKind + offset + length
```

The identity is deliberately:

- build-local and transient; it is not a snapshot, Cache, Hot Reload, or
  cross-edit stable identity;
- pointer-free and exact; there is no node-address, offset-only, nearest-range,
  or ambiguous-match fallback;
- idempotent for the same identity/value pair;
- fail-closed for the same identity with a different declaration, expression,
  or target type, preserving the first binding and publishing a deterministic
  conflict diagnostic;
- a Parser/Builder coordination value only, not a semantic AST node and not a
  replacement for stable declaration/type/runtime relocation keys.

The resulting ownership boundary is:

```text
Parser owns native asCScriptNode syntax/recovery/LEGACY state
    -> Parser copies exact section/kind/range after the relevant grammar phase
    -> Canonical Sema stores only asSParseActionIdentity -> Canonical ID/type
    -> Builder copies the same exact coordinate only to bind prepared Runtime shells
```

The native Parser tree, `asCBuilder`, and `asCCompiler` remain independently
available for syntax/recovery, explicit LEGACY, reference, differential tests,
and rollback. HIR remains physically absent.

## AST-first gate

Permanent tests are in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`:

- `ParseActionIdentityIsPointerFreeExactAndConflictRejecting`
  - proves exact copied identity;
  - proves same-value rebinding is idempotent;
  - proves declaration/expression/target-type conflicts reject, preserve the
    first binding, and emit deterministic diagnostics;
  - proves `length` participates in identity.
- `CanonicalSemaStoresNoNativeParserNodeIdentity`
  - proves the Sema API/storage declares `asSParseActionIdentity`;
  - proves `as_sema.h/.cpp` contain no `asCScriptNode` dependency.

Valid RED:

`Saved/Build/cta-s54-parse-action-identity-red/20260829_074944_916_43d518c5`

The test-first build failed because `asSParseActionIdentity` and its APIs did
not exist. This is the valid product RED.

The first implementation build then failed at 15 existing test callers that
still passed `asCScriptNode*` to the removed API:

`Saved/Build/cta-s54-parse-action-identity-build1/20260829_075353_010_b76b16b7`

After migrating those callers, the implementation build passed:

`Saved/Build/cta-s54-parse-action-identity-build2/20260829_075459_812_6bdbcc9b`

## Problems found and fixes

### 1. One focused command selected no tests

`Saved/Tests/cta-s54-parse-action-identity-focused/20260829_075524_662_5f77ba06`

The command guessed the wrong CQTest class path and reported `No automation
tests matched`. It is infrastructure/no-selection evidence only and is
explicitly excluded from behavioral GREEN evidence. Later commands used the
discovered `FCanonicalASTSemaAuthorityTests` path.

### 2. Exact identity exposed growing cast/construct ranges

The first complete SemaAuthority run was **400/405 PASS**:

`Saved/Tests/cta-s54-parse-action-identity-sema-full/20260829_080032_940_e370b7b8`

The five failures were:

- `AlwaysImplementDefaultConstructSealsAndBindsGeneratedZeroArgConstructor`
- `ParserActOnCastBeforeCloseParenFails`
- `ParserActOnPrimitiveFunctionalCastBeforeArgListCloseFails`
- `ParserCastExprActionBindsExactOperandAndTargetWithoutNodeReplay`
- `ParserConstructExprActionBindsScalarAndObjectFormsWithoutNodeReplay`

For cast/construct, Parser bound the target type before the enclosing
`snCast`/`snConstructCall` source range was complete. The old pointer identity
hid this timing bug because the address stayed constant; exact copied identity
correctly observed a short bind range and a longer lookup range.

The repair keeps the resolved target type in Parser-local state, completes or
recovers the expression range, then binds the target type and publishes the
typed expression action under that final exact identity. No fuzzy lookup was
added.

Build after this repair:

`Saved/Build/cta-s54-parse-action-identity-range-fix-build/20260829_080429_102_3ee03ca7`

### 3. Exact identity exposed growing declaration-wrapper ranges

The remaining generated-constructor failure initially reported only that no
producer-bound constructor matched:

`Saved/Tests/cta-s54-generated-default-identity-diagnose/20260829_080442_946_e788e89b`

Bounded failure-path diagnostics were added to count owner-kind, live, keyed,
and signature candidates. The diagnostic sequence was:

- diagnostic build PASS:
  `Saved/Build/cta-s54-generated-default-diagnostic-build/20260829_080537_925_3a4d858d`;
- second run: `ownerKind=2 live=2 keyed=1 signature=0`:
  `Saved/Tests/cta-s54-generated-default-identity-diagnose2/20260829_080550_930_2f15356b`;
- extended diagnostic build PASS:
  `Saved/Build/cta-s54-generated-default-diagnostic2-build/20260829_080650_935_7ae894ab`;
- third run showed the factory had one parameter while the only keyed
  constructor had zero:
  `Saved/Tests/cta-s54-generated-default-identity-diagnose3/20260829_080704_042_60048be3`.

The root cause was not generated-constructor selection. Authored function,
constructor, lambda, funcdef, import, class, and interface declarations need an
early Decl identity for parameters and `DeclContext`, but their outer native
wrapper range continues growing until `;`, body, or closing brace. Builder
later queries the completed wrapper coordinate. The authored constructor
therefore lacked a final stable declaration key, leaving only the generated
zero-argument constructor keyed.

The repair keeps the early binding for incremental declaration composition and
adds the same `DeclId` under the completed exact wrapper identity after the
grammar family reaches its final range. It does not mutate a stored node,
retain a node pointer, or recover by offset alone.

Build and exact regression:

- `Saved/Build/cta-s54-completed-decl-identity-build/20260829_080912_575_a76ad0a0`
  — PASS;
- `Saved/Tests/cta-s54-generated-default-identity-green/20260829_080926_314_e9fc3927`
  — **1/1 PASS**.

The enhanced candidate diagnostic remains on the bounded failure path because
it makes future generated constructor/factory identity failures attributable
without changing successful behavior.

### 4. Conflict behavior needed explicit diagnostic proof

Diff review found that Decl/Expr conflicts were tested, but target-type
conflict preservation and all three diagnostic tokens were not explicit. The
implementation and gate were strengthened with:

- `declaration-identity-bind-conflict`;
- `expression-identity-bind-conflict`;
- `expression-target-type-bind-conflict`.

Evidence:

- `Saved/Build/cta-s54-identity-conflict-diagnostic-build/20260829_081727_942_e853b5b6`
  — build PASS;
- `Saved/Tests/cta-s54-identity-conflict-diagnostic-green/20260829_081747_411_b3ea5c26`
  — exact **1/1 PASS**;
- `Saved/Tests/cta-s54-parse-action-identity-sema-final/20260829_081827_531_c983c0b1`
  — complete SemaAuthority **405/405 PASS**, proving no existing producer path
  contains a hidden conflicting exact identity.

## Final verification

The first repaired full Sema run was also **405/405 PASS**:

`Saved/Tests/cta-s54-parse-action-identity-sema-green/20260829_081000_987_51e5c948`

The first cross-consumer regression was **186/186 PASS**, 0 failed, 0 skipped:

`Saved/Tests/cta-s54-parse-action-identity-consumer-regression/20260829_081413_044_ce192fab`

After adding the deterministic conflict diagnostics, the same exact consumer
set was rerun and remained **186/186 PASS**, 0 failed, 0 skipped:

`Saved/Tests/cta-s54-parse-action-identity-consumer-final/20260829_082157_915_0b7f61b9`

It selected these exact prefixes:

- `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`
- `Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot`
- `Angelscript.TestModule.StaticJIT.TypedASTJIT`

Some TypedASTJIT provider tests logged an external connectivity-probe timeout
warning, but every corresponding test completed successfully and the exported
summary remained 186/186. The warning is not counted as compiler failure or as
positive evidence.

Final source and formatting scans:

```text
as_sema.h/.cpp: asCScriptNode = 0
as_sema.h/.cpp: firstChild = 0
as_sema.h/.cpp: lastChild = 0
as_sema.h/.cpp: ->next = 0
production AngelScript source: asCHIR/as_hir/HIRFunction/TypedSemanticIR = 0
git diff --check = PASS
```

## Non-claims and remaining work

- This closes the residual native-node **identity-storage** dependency in
  Canonical Sema; it does not claim every declaration/expression/statement/
  lifetime language family and Sema environment rule is complete.
- Tasks 4.2 and 13.2 remain open until their full typed-action inventory,
  semantic coverage, Frozen/Publishable facts, and backend-mechanical-only
  requirements are proven.
- This does not make CANONICAL the product default and does not close Tasks
  10.1-10.9 or final regression tasks.
- The native AngelScript AST/Parser/Builder/Compiler are intentionally retained;
  physical native-AST retirement is deferred to a separate future OpenSpec.
- HIR remains absent and is not recreated as an adapter.
- AOT and Bytecode consume sealed Canonical AST/protocol facts directly; no
  dump transport was introduced or required.
- Standalone was explicitly deferred by user direction and was neither changed
  nor run for CTA-S54.
- The formal checklist remains **100/136 (73.5%)** because CTA-S54 narrows two
  broad unchecked umbrella tasks but does not by itself satisfy either task in
  full.
