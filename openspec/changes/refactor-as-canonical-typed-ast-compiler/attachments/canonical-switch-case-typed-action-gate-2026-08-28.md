# Canonical switch/case typed-action gate — 2026-08-28

## Outcome

CTA-S42 has completed the structured-control Parser-to-Sema migration.
`switch`, `case` and `default` now publish Canonical semantics through
pointer-free typed actions carrying exact AST identities and copied source
coordinates. Together with the earlier loop slice, all currently implemented
structured control families now establish and finish their semantic identity
without replaying a completed `asCScriptNode`.

The native AngelScript AST is still intentionally built and retained for
syntax, recovery, the explicit LEGACY compiler, reference and differential
testing. This gate removes it only as the CANONICAL semantic input for these
statement families. It does not authorize deleting the native AST.

## Architecture now implemented

```text
ParseSwitch closes the selector/header
  -> asSControlStatementHeaderAction(SWITCH)
  -> Sema creates and pushes the exact Switch StmtId
  -> ParseCase/ParseDefault publishes exact value + ordered child StmtIds
  -> leaf break/fallthrough already freeze the current exact control context
  -> asSSwitchStatementAction submits ordered exact Case identities
  -> Sema validates parent/owner/order, fills the original Switch StmtId
  -> Sema wires every fallthrough to the exact next Case StmtId
  -> Sema marks switch safe-point metadata and pops only its owned control
```

`asSCaseStatementAction` distinguishes case/default explicitly. A case carries
one exact optional value expression and its exact ordered children; a default
must not carry a value. `asSSwitchStatementAction` carries the exact selector,
the pre-published switch control and the ordered exact case identities.

Parser obtains the enclosing switch identity through
`CurrentSwitchControl()`, which scans the private Sema construction stack for
the nearest exact Switch StmtId. Sema still requires that identity to be the
current stack top when publishing a case, so a leaked or mismatched nested
control fails closed rather than attaching the case to a guessed parent.

## Retired transition bridge

The temporary `(statement kind, owner, file, begin offset)` lookup was needed
only while Block/If had exact child actions but loop/switch headers still used
native adapters whose final ranges grew after body parsing. After the complete
loop and switch migration, both `BeginParsedControl` and
`FindStatementActionIdentity` have been physically removed.

Completed `snSwitch` and `snCase` semantic cases are also physically absent
from `ActOnParsedStmt` and `ActOnStmtFromNode`. Native kind mappings retained
for syntax-oriented compound helpers are not a semantic replay path and do not
alter the native-AST retention decision.

## TDD and verification evidence

- expected missing-contract RED build:
  `Saved/Build/cta-s42-switch-case-action-red/20260828_061229_824_2557a40a/RunMetadata.json`;
- first implementation build exposed one mechanical C++ cleanup error after
  the last two legacy cases were removed: `ActOnParsedStmt` contained a
  `switch` with only `default`, rejected by C4065:
  `Saved/Build/cta-s42-switch-case-action-build-1/20260828_062002_324_7ac7bfcd/RunMetadata.json`;
- repaired GREEN build:
  `Saved/Build/cta-s42-switch-case-action-build-2/20260828_062030_096_6c95586b/RunMetadata.json`;
- new exact action, parser integration and physical-boundary tests **3/3
  PASS**:
  `Saved/Tests/cta-s42-switch-case-action-focused-new-1/20260828_062052_094_f9397003/RunMetadata.json`;
- existing switch/default/fallthrough/break, safe-point and recovery regression
  set **10/10 PASS**:
  `Saved/Tests/cta-s42-switch-case-action-regression-1/20260828_062302_161_99707505/RunMetadata.json`;
- complete SemaAuthority **392/392 PASS**:
  `Saved/Tests/cta-s42-switch-case-sema-authority-full-1/20260828_062447_874_bf24afab/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  downstream gate **158/158 PASS**:
  `Saved/Tests/cta-s42-switch-case-secondary-gates/20260828_063033_755_2365aab4/RunMetadata.json`.

## Problems found and decisions

1. **Case construction needs the parent before the switch body is complete.**
   The header action now returns/pushes the exact Switch StmtId before any case
   is parsed. Case actions never rediscover a parent from native source shape.
2. **Fallthrough is an ordered sibling relationship.** The case action records
   exact ordered children, while the switch finish action alone wires each
   fallthrough to the next exact Case StmtId. Parser does not synthesize or
   guess the target.
3. **Default is not a case with an invented expression.** The action kind is
   explicit and Sema rejects a default carrying a value.
4. **Recovery must not hide a leaked control.** Case publication accepts the
   nearest exact switch identity but Sema requires it to be the current top;
   mismatch is diagnostic and fail-closed. Switch finish pops only the exact
   control it owns.
5. **Physical removal can leave invalid C++ scaffolding.** Once the final
   native semantic cases were deleted, the adapter's switch contained only a
   default label. The repair replaced it with a direct fail-closed delegation;
   no semantic fallback was restored and no test was weakened.

## Progress and remaining boundary

No umbrella `tasks.md` row is fully closed because statement lifetime/cleanup,
full detached CodeGen, TypedASTJIT/AOT consumption and production cutover are
still open. Mechanical progress therefore remains **87/125 (69.6%)**.

The dependency/risk-weighted implementation estimate advances to **about
74%**. Safe production default-cutover readiness is **about 47%**. The
Parser-to-Sema action-only semantic-authority migration is **about 98%**: all
primary declaration, expression and structured-statement paths use typed
actions, while residual uncommon semantic/lifetime surfaces and construction
helpers still need audit and closure.

The next critical slice is explicit lifetime/cleanup authority and the
remaining uncommon body forms, followed by detached Canonical Bytecode
CodeGen/runtime relocation breadth and direct TypedASTJIT/AOT visitors. The
compiler default remains LEGACY.
