# Sixth-pass findings verified against live `D:\as-cta` (2026-08-22)

Source: `reviews/implementation-rereview-2026-08-22-sixth-pass.md`.
Reviewer snapshot was SemaAuthority **170/170**. Live intern is now **178/178**. The CodeGen ABI findings were re-read against current `as_bytecode_codegen.cpp` / `as_builder.cpp`. **Request changes stands.** Do not archive. Do not check 13.2 / 9.5 / 10.2.

## Verdict after verification

The sixth-pass diagnosis is still accurate: CANONICAL `Generate()` is a real opt-in production route, but several new surfaces generalize **int-only fixtures** into wrong runtime ABI. Intern peels (postfix `()` / named decls) do not close that.

| Finding | Live? | Evidence |
| --- | --- | --- |
| **F1** class registered `asOBJ_VALUE \| asOBJ_NOINHERIT`, alignment 4, bare-name skip | **Flags landed; remainder open** | `asAST_TRAIT_VALUE` on `ttStruct`. class REF+IMPLICIT_HANDLE, struct VALUE. Alignment 4 / silent property `continue` / nested ns / bare-name host collision still open. |
| **F2** integer global `atoi(defaultArg)` + 32-bit write | **Landed (slice)** | Parser full-parse global init when `sema != 0`; `EvalIntegerConst`; CodeGen `strtoll` fail-closed + width by type size. ProductionCodeGen **28/28**, Compiler **409/409**. Not 9.5. |
| **F3** accessor/list factory hard-coded `RDR4`/`WRTV4` / 4-byte stride | **Landed (slice)** | `ValueDwords` + `EmitReadValue`/`EmitWriteValue` from property/list-pattern size. ProductionCodeGen **32/32**, Compiler **413/413**. Not 9.5. |
| **F4** (sixth) module-global capture uniquing + sibling IIFE execute | **Landed (slice)** | Uniquing `[captureBegin, end)` was already in source. Execute 13732 was **not** capture inject: `ActOnStmtFromNode` snStatementBlock interned every local-init ASSIGN/DECL_REF at the **enclosing block** range, so `A=IIFE`/`B=IIFE` collapsed onto `X=21`. F never CALLed either lambda; A+B was uninit stack (13732 / 10682532). Isolation `return IIFE()+IIFE()` was 42 (`wave-d-f4-diag-sib2`). Fix: per-declaration range. ProductionCodeGen **33/33** `wave-d-f4-prod3`. Compiler **414/414** `wave-d-f4-compiler`. Capture plan still CodeGen-owned. **Not 9.5 / 13.2.** |
| **F5** LEGACY lambda `snIdentifier("function")` counted as param | **Landed (slice)** | `ImplicitConvLambdaToFunc` + `RegisterLambda` enter `snParameterList`. Late `$` lambda now `CalculateParameterOffsets` after `RegisterScriptFunction` (layout ran before `CompileFunctions`). 0-arg and 1-arg host `Invoke` execute 42, publisher `COMPILER`. RED `wave-d-f5-exec-red` 1/2: `types=1 offsets=0` assertion, no AV. GREEN Legacy **2/2** `wave-d-f5-exec`. Compiler **416/416** `wave-d-f5-compiler`. **Not 9.5 / 13.2.** |
| **F6** types/imports mutate live Engine before emission; Abandon does not unregister types | **Yes** | register at `:2403-2406`; `artifact.globals` unused |

F7–F12 (int placeholder types, verifier holes, Cache sidecar, snapshot ABI, CompileFunction mixed) are still open. They are **not** this UBT.

Existing ProductionCodeGen **25/25** fixtures that need VALUE layout use **`struct FValue`**, not `class`. That is why F1 and 25/25 can both be true.

## Next exclusive UBT (live)

**B-frontend-codegen landed.** Frontend **82/82** `wave-b-frontend-codegen`, CanonicalAST **242/242** `wave-b-frontend-canonical`. Next intern leftover: param list / enumerator (weak) or capture-plan research (`attachments/wave-b-leftover-after-nested.md`). Live 梳理: `attachments/async-work.md`.

F4 execute **landed**. F5 arity/names + 0-arg **and** 1-arg execute 42 **landed**. B-ctor-dtor-mixin / B-list-pattern / B-inc / B-body-attach / B-nested-extract intern / B-frontend-codegen **landed**. **Leave 9.5 / 13.2 `[ ]`.**

Must not next: F1 remainder as 9.5 close, F6 atomic install, capture-plan-in-Sema as a 13.2 close, default CANONICAL, 13.2/9.5 check, re-enable `@`.

F2 atoi **landed**. F3 ABI **landed**. F4 uniquing + sibling execute **landed**. F5 conversion + execute **landed**. B-ctor-dtor-mixin / list-pattern / ++/-- **landed**. After those: leftover intern `B-body-attach` (`wave-b-body-attach-next.md`).

### D-sixth-f4-exec (landed, not 9.5 close)

- RED `wave-d-f4-prod2`: ProductionCodeGen **32/33**, execute **13732** — `D:\as-cta\Saved\Tests\wave-d-f4-prod2\20260822_093552_194_0829c0a2`
- Isolation `wave-d-f4-diag-sib2`: `return IIFE()+IIFE()` **42**; A+B still garbage **10682532**; F CALL neither lambda — `D:\as-cta\Saved\Tests\wave-d-f4-diag-sib2\20260822_095507_671_f0936622`
- GREEN ProductionCodeGen `wave-d-f4-prod3`: **33/33** — `D:\as-cta\Saved\Tests\wave-d-f4-prod3\20260822_100033_147_bfae7689`
- GREEN Compiler `wave-d-f4-compiler`: **414/414** — `D:\as-cta\Saved\Tests\wave-d-f4-compiler\20260822_100115_242_5b3787de`

Still open after F4: capture plan CodeGen-owned, stored capturing closures. F5 1-arg execute is now landed below. **9.5 stays `[ ]`.**

### D-sixth-f5-exec (landed, not 9.5 close)

Late `RegisterLambda` (inside compiling `F()`) copied `parameterTypes`/`parameterNames` but never called `CalculateParameterOffsets`. Empty `asCArray` (`array=0`) made `SetArgDWord` AV at address 0. Production: `RegisterLambda` layouts the `$` function after `RegisterScriptFunction` succeeds.

- RED `wave-d-f5-exec-red`: Legacy **1/2** — ZeroArg Success; OneArg Fail `types=1 offsets=0` (no AV) — `D:\as-cta\Saved\Tests\wave-d-f5-exec-red\20260822_104259_341_a6c56107`
- GREEN Legacy `wave-d-f5-exec`: **2/2** ZeroArg + OneArg `F()` execute 42 — `D:\as-cta\Saved\Tests\wave-d-f5-exec\20260822_104409_343_5815ad2b`
- GREEN Compiler `wave-d-f5-compiler`: **416/416** (F4 414 + these two Core methods) — `D:\as-cta\Saved\Tests\wave-d-f5-compiler\20260822_104502_614_a87ab302`

Still open after F5: capture plan CodeGen-owned, stored capturing closures, script `funcdef`/`@`, CANONICAL CompileFunction, F6 atomic install. **9.5 / 13.2 stay `[ ]`.**

## D-sixth-f1 flags slice (landed, not 9.5 close)

Sema records `asAST_TRAIT_VALUE` on `snClass` when `tokenType == ttStruct`. `RegisterCanonicalScriptTypes` registers `class` as `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE` and `struct` as `asOBJ_VALUE | asOBJ_NOINHERIT`, and AddRefs copied `scriptTypeBehaviours` construct/copy/factory like legacy Builder.

- RED `wave-d-f1-red`: ProductionCodeGen crashed on Engine destroy (`ReleaseAllFunctions` / `atomicDec` at `0x14`) while registering `class ActorLike` as VALUE without AddRef — `D:\as-cta\Saved\Tests\wave-d-f1-red\20260822_083124_583_2e3765dc`
- GREEN ProductionCodeGen `wave-d-f1-prod`: **26/26** — `D:\as-cta\Saved\Tests\wave-d-f1-prod\20260822_083345_228_67d5b27a`
- GREEN Compiler `wave-d-f1-compiler`: **407/407** — `D:\as-cta\Saved\Tests\wave-d-f1-compiler\20260822_083434_445_87d8c10a`

Still open in F1: alignment-from-properties, silent `continue` on bad property, nested-namespace class, bare-name host collision. **9.5 stays `[ ]`.** Next intern slice after ctor/dtor/mixin: `snListPattern` (`wave-b-leftover-after-postfix.md`).
