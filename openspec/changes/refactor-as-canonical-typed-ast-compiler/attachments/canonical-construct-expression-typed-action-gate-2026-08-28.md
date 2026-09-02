# CTA-S31 — construct-call typed-action gate (2026-08-28)

## Scope

This gate migrates the complete native `snConstructCall` expression boundary
from generic Parser notification / Sema native-node replay to one pointer-free
typed action. It covers both meanings carried by the grammar form `TYPE
ARGLIST`:

- a primitive or enum functional cast with exactly one argument seals a
  canonical `Conversion`; and
- an object construction seals the selected `Construct` plus its existing
  materialization / cleanup plan.

The retained `snConstructCall`, `snDataType`, `snArgList`, Parser, Builder and
LEGACY compiler remain physically available for syntax, recovery, explicit
LEGACY compilation, differential testing, reference and rollback. CANONICAL
Sema must not walk that retained subtree after this family is complete.

## Required action contract

`asSConstructExprAction` must own only build-local canonical facts and copied
source coordinates:

- the exact Parser-resolved target `asCQualType`;
- ordered exact argument `asASTExprId` values;
- the complete half-open processed-source range.

No `asCScriptNode`, token-buffer pointer, Runtime pointer, numeric Runtime
`TypeId`, dump payload or HIR identity may cross the action boundary.

## AST-first tests

The direct action gate will be added to
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` and will construct the
action without a native syntax node. It must prove:

- a scalar target and one exact argument produce `Conversion`, not
  `Construct` / `MaterializeTemporary`;
- an object target and exact argument produce a selected typed `Construct`;
- the result owns the exact target and exact argument identity; and
- a distinct same-range argument cannot be substituted by range reuse.

The Parser gate will parse one primitive functional cast and one object
construction and assert both sealed forms. It will also inspect the isolated
`ParseConstructCall` source boundary and require a dedicated bind helper while
forbidding generic `ActOnParsedExpr` notification in that function.

## RED baseline

Status: **observed as intended**.

The first build is RED because `asSConstructExprAction` and
`asCSema::ActOnConstructExprAction` do not exist. UBT reports those exact
missing symbols from the new direct action test; no production source has been
changed for this RED:

`Saved/Build/cta-s31-construct-action-api-red/20260828_004825_872_7b5f0958/RunMetadata.json`

After that API is implemented, the Parser gate must remain RED until
`ParseConstructCall` builds and binds the action rather than calling
`ActOnParsedExpr(node, script)`.

The corrected direct action fixture is **1/1 PASS** after the API is present:

`Saved/Tests/cta-s31-construct-action-direct-green-fixed/20260828_005222_721_f15a5c38/RunMetadata.json`

The Parser test then produces the intended second RED: both semantic forms are
visible only because the old generic replay still runs, while the isolated
`ParseConstructCall` source slice has no `BindConstructExprAction` and still
contains `ActOnParsedExpr`. The dedicated boundary assertion fails:

`Saved/Tests/cta-s31-construct-parser-action-red/20260828_005256_110_f049d065/RunMetadata.json`

### CTA-S31-I1 — direct class fixture assumed `Decl::type`

The first direct behavioral run after adding the action API is **0/1**, because
the fixture assumed `ActOnClassDecl` writes an expression-ready value type into
`ClassDecl::type`. That is not this Sema API's contract; existing direct
constructor tests explicitly intern the canonical named value type. The
failure occurs before `ActOnConstructExprAction` is invoked and therefore is
not evidence of a production action defect. The fixture now owns class `T` and
separately interns `asAST_TYPE_VALUE_OBJECT` key `T` before exercising the
action:

`Saved/Tests/cta-s31-construct-action-direct-green-exact/20260828_005110_187_15d60d37/RunMetadata.json`

## Production migration gate

After both tests have demonstrated the expected RED:

1. add the pointer-free action and Sema entry point;
2. add bounded Parser build/bind helpers using exact child identities;
3. bind on successful and complete recovery exits where the target and every
   argument are already available;
4. change complete native `snConstructCall` adaptation to exact identity-only
   lookup with a deterministic missing-action diagnostic; and
5. run the focused tests, complete SemaAuthority, ProductionCodeGen,
   Canonical Semantics and retained native ScriptNode regressions.

## Non-claims

This slice does not complete ordinary/member/import/native calls, structural
postfix member/index/call stages, initializer lists, general statements,
default arguments, lifetime closure, full CodeGen/AOT or default CANONICAL
cutover. Task 4.2, 5.2, 5.3, 5.4, 10.6 and 13.2 remain open unless their full
scope is independently proven.

Named constructor arguments are also not claimed by this bounded action.
`BuildConstructExprAction` fails closed when it sees a named-argument wrapper;
it does not drop the name or fall back to native-tree semantic replay. The
complete ordinary/member/constructor call-plan action must later own argument
name, source/default/hidden origin, formal-order mapping and receiver
provenance as one sealed contract.

## GREEN closure

Status: **complete for the bounded construct-expression family**.

The implemented boundary is:

1. Parser resolves the target type and every positional argument to exact
   canonical identities;
2. `asSConstructExprAction` copies those facts without native or Runtime
   pointers;
3. Sema seals primitive/enum functional casts as `Conversion` and object
   construction as selected `Construct` plus its existing materialization and
   cleanup plan;
4. Parser binds the returned exact parent identity; and
5. complete native `snConstructCall` adaptation is identity-only and reports
   `construct-expression-action-missing` if the action was not published.

The retained native syntax nodes are unchanged and remain available to the
explicit LEGACY path, syntax/recovery tests, differential/reference work and
rollback.

Final evidence:

| Gate | Result | Evidence |
| --- | ---: | --- |
| direct pointer-free construct action | **1/1 PASS** | `Saved/Tests/cta-s31-construct-action-direct-green-fixed/20260828_005222_721_f15a5c38/RunMetadata.json` |
| Parser scalar/object action boundary | **1/1 PASS** | `Saved/Tests/cta-s31-construct-parser-action-green/20260828_005422_519_5bcac138/RunMetadata.json` |
| complete SemaAuthority | **359/359 PASS** | `Saved/Tests/cta-s31-sema-authority/20260828_005458_091_af90cdff/RunMetadata.json` |
| complete ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-s31-production-codegen/20260828_005537_226_bd749496/RunMetadata.json` |
| Canonical Semantics | **12/12 PASS** | `Saved/Tests/cta-s31-canonical-semantics/20260828_005712_116_88a3f588/RunMetadata.json` |
| retained native ScriptNode | **32/32 PASS** | `Saved/Tests/cta-s31-native-scriptnode/20260828_005748_235_1dc41e13/RunMetadata.json` |

Parser generic `ActOnParsedExpr` call sites fall from **6** to **5**. The five
remaining sites belong to ordinary calls, initializer-list exits and
structural postfix member/index/call routes; they are not waived by this gate.
