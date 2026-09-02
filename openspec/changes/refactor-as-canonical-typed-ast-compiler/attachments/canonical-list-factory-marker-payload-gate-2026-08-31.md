# Canonical list-factory Marker payload gate (2026-08-31)

`FSemaListBox Box = {41}` compiles and CALLSYS/STOREOBJ the registered list
factory. `Box.Marker` is a `MEMBER_REF` of an implicit-handle local, so
CodeGen PSF of the handle slot reads the handle bits (or null) instead of the
native `Marker` written from `{41}` / `{41.25}` / `{1,2,3}`.

List-factory intern also skipped the buffer formal only when parameter 0 was a
non-primitive reference, so `T f(int &in) {repeat int}` kept the buffer as an
authored formal.

This advances `5.9`, `9.5`, and `13.6` for list-factory payload and aggregate
committed-prefix execute. It does not close those umbrellas or native factory
ranking.

### Gate card: list-factory dest is a handle slot; Marker is MEMBER_REF of that object

- **OpenSpec task(s):** `5.9`, `9.5`, `13.6` (slice)
- **Source fixture:**
  - `FSemaListBox Box = {41}; return Box.Marker + 1;`
  - `FSemaDoubleListBox Box = {41.25}; return Box.Marker + 1;` (WRTV8)
  - aggregate `{MakeAggregateElement(1), (2), (3)}; return Box.Marker;`
    expecting `123` on the success path.
  Methods `CanonicalListFactoryBuildPublishesCodeGenAndExecutes`,
  `CanonicalListFactoryDoubleUsesWrtv8NotWrtv4`,
  `CanonicalAggregateListCommitsEachElementAndUnwindsOnlyCommittedPrefix`.
- **Canonical fact:** CONSTRUCT `"list-pattern"` binds `asAST_TRAIT_LIST_FACTORY`;
  intern skips the list buffer formal when `listPattern != 0`; dest is the
  local handle slot (`STOREOBJ`); `DECL_REF` of that handle is a PshVPtr slot
  so `MEMBER_REF Marker` observes the factory payload.
- **AST test:** ProductionCodeGen methods above.
- **AST-red:** `cta-list-factory` `20260831_203653_732_7d5ac1c4` and
  `cta-aggregate-list` `20260831_203722_853_0bf83365`. Build succeeds; execute
  Marker is garbage / not `123`.
- **AST-green:** `cta-list-factory` `20260831_205943_713_e75c758b` **2/2** and
  `cta-aggregate-list` `20260831_210013_076_6637694f` **1/1**. Repair: handle
  `DECL_REF` is a PshVPtr slot; list intern skips the buffer formal when
  `listPattern != 0`.
- **CodeGen/provenance:** `EmitListFactoryInto` already CALLSYS `beh.listFactory`
  + `STOREOBJ dest`. The Marker-garbage path is `EmitLValueAddress` `DECL_REF`.
- **Lifecycle:** N/A.
- **Focused regression:** implicit-handle prvalue 2/2 is a different node kind
  (`MATERIALIZE_TEMPORARY` / `CALL`), not this local `DECL_REF`. Full
  ProductionCodeGen **196/196** (`cta-ast-first-codegen`
  `20260831_210231_401_c5b5ef43`). SemaAuthority **474/474**. This card does
  not close 5.9/9.5/13.6.
- **Remaining boundary:** nested/omitted/repeat-same list-pattern CodeGen,
  native factory ranking, lexical owning-handle release, product-default
  cutover.
