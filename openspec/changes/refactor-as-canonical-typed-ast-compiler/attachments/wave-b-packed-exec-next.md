# Wave B exclusive UBT — packed int8 execute 1934

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-packed-exec**. **LANDED 2026-08-23** (execute 1934/902). Not 13.2.

Companions: `attachments/async-work.md` §4; `attachments/async-dispatch.md`; `attachments/wave-b-abi-width-next.md` leftover.

**Do not check 13.2 / 9.2 / 9.5 / 5.4.** Opcode WRTV1 is already GREEN. This bite is **execute**.

Do **not** pad `int8` members to 4. Do **not** restore `WRTV4` on packed stores. Do **not** restore `GetFirstProperty`, dummy CONSTRUCT, ordinal sibling-VAR, last-loop break, name+arity global bind.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Exclusive-UBT TDD + systematic-debugging |
| Gate | Construct-init GREEN. Opcode lock GREEN. Execute historically `got=0` |
| Do not mark | **13.2 / 9.2 / 9.5 / 5.4 / 4.2 / 10.2** |

---

## 0. What is already true

`CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4` (`ProductionCodeGenTests.cpp:2345`):

- `FPackedBytes { int8 A,B,C,D }` — `B` property offset **1** (not dword-aligned).
- `FPair16Words { int16 Lo, Hi }` — `Hi` offset **2**.
- Generated `SetB` (if present) or `RunPacked` MemberRef contains **`WRTV1` not `WRTV4`**.
- Generated `SetLo` contains **`WRTV2` not `WRTV4`**.
- **Does not currently execute** `RunPacked` / `RunPair16`. Execute oracles were added, RED `got=0`, then **reverted** so ProductionCodeGen stays 48/48.

RED evidence (do not treat as current test body):

`Saved/Tests/wave-b-packed-exec-red-prod/20260822_234717_191_3cdf7074`

```
packed int8 neighbor store must execute 1934 (WRTV1), not smash C/D; got=0
```

`1934` = `1*1000 + 9*100 + 3*10 + 4` after `A=1,B=2,C=3,D=4` then `B=9`.
`got=0` means **all four fields read as 0**, not neighbor smash. Smash of B into A/C would look like `1900` / `1930` / similar, **not 0**.

Working comparison that **must stay 42**:

- `CanonicalGeneratedAccessorBuildPublishesCodeGenAndExecutes` — `struct FValue { int Value; }` `Object.Value = 41; return Object.Value + 1` via generated Get/Set, **WRTV4/RDR4**, execute **42**.
- InitPlan `FValue Object;` with `int Value = 41` execute **42**.

---

## 1. TDD first (re-assert execute)

In `CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4`, **keep** the opcode + offset asserts. **Add**:

```cpp
int32 PackedValue = 0;
ASSERT_THAT(IsTrue(
    CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int RunPacked()", PackedValue)
        && PackedValue == 1934,
    *FString::Printf(
        TEXT("packed int8 neighbor store must execute 1934 (WRTV1), not smash C/D; got=%d"),
        PackedValue)));
int32 PairValue = 0;
ASSERT_THAT(IsTrue(
    CanonicalExecuteInt(*TestRunner, Engine.Get(), Module, "int RunPair16()", PairValue)
        && PairValue == 902,
    *FString::Printf(
        TEXT("packed int16 neighbor store must execute 902 (WRTV2); got=%d"),
        PairValue)));
```

`902` = `9*100 + 2` after `Lo=1, Hi=2` then `Lo=9`.

Watch RED on ProductionCodeGen (`wave-b-packed-exec-red-prod2` or similar). Expected: **47/48** or **46/48**, fail message `got=0` (or pair `got=0`). If the test **passes immediately**, you did not restore the execute oracle — stop.

Then **stop guessing**. Systematic-debug before any CodeGen change.

---

## 2. Systematic-debug `got=0` (before any fix)

Iron law: no emit change until a confirmed root cause.

### 2.1 Reproduce

Prefix: `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`
Label: `wave-b-packed-exec-red-prod2`
Always `RunBuild.ps1` first after test-body edit (`RunTests.ps1` does not UBT). `-NoXGE`. `ProjectFile=D:\as-cta\AngelscriptProject.uproject`.

If UBT says up to date and behavior unchanged: delete

- `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll`
- `Intermediate/.../AngelscriptRuntime/Module.AngelscriptRuntime.44.cpp.obj` (codegen `.44`)

then rebuild.

### 2.2 Compare working vs broken

| Path | Width | Opcode lock | Execute |
| --- | --- | --- | --- |
| `FValue.Value` int Get/Set | 4 | WRTV4/RDR4 | **42 GREEN** |
| `FPackedBytes.B` int8 Get/Set or MemberRef | 1 | WRTV1 GREEN | **0 RED** |
| `FPair16Words.Lo` int16 | 2 | WRTV2 GREEN | historically unasserted |

Dump bytecode of:

1. generated `SetB` / `GetA` / `GetB` (if installed)
2. `int RunPacked()`
3. working `FValue::SetValue` / `GetValue` / `int F()`

Ask, with evidence:

- Does `RunPacked` CALL generated Get/Set (like FValue) or inline MEMBER_REF?
- Does local `FPackedBytes p;` construct (VAR `inits` CONSTRUCT / sibling assign)? Dummy CONSTRUCT is deleted; missing construct fail-closes Build — Build **succeeded**, so a construct path exists.
- Do stores write the object that loads read (`this` PSF+RDSPtr vs pointer-width, ADDSi offset 0/1/2/3)?
- Does Get copy a 1-byte RDR1 into a 4-byte returnSlot via `CopyVar(..., returnDwords)` and then LoadReturn the wrong dword?
- Are generated Set params the 4-byte stack slot while WRTV1 writes only the low byte of a **zeroed** src?

### 2.3 Hypotheses (one at a time)

Write the hypothesis, make the **smallest** probe, do not stack fixes.

| # | Hypothesis | Why it would yield 0 | Disproof |
| --- | --- | --- | --- |
| H1 | WRTV4 smash | Would typically yield ~1900 not 0 | Opcode already WRTV1. **Do not “fix” by restoring WRTV4** |
| H2 | Stores never run / write 0 | All fields stay default 0 | Bytecode of RunPacked / SetB; src slot of WRTV1 |
| H3 | Loads read a different object or offset | Gets return 0 | ADDSi offsets vs sealed `byteOffset` 0,1,2,3 |
| H4 | VALUE `this` ABI (PSF vs object pointer) wrong for 1-byte RDR | Get always 0 even if memory written | Compare FValue GetValue (works at 4 bytes) |
| H5 | `CopyVar`/`LoadReturn` 4-byte on 1-byte dest zeros or drops | Return is 0 | Getter body after RDR1 |
| H6 | generated Set name-strip binds the wrong field | Writes A or nothing | `EmitGeneratedAccessor` strips `Get`/`Set` then `FindFieldOffset` |

Do **not** pad int8 to 4 to make WRTV4 “work”. Packed layout offset **1** is the lock.

### 2.4 If 3 probes fail

Stop. Record what you proved in `wave-b-results.md`. Do not attempt Fix #4 without writing the evidence. Question whether generated accessors can carry a sealed field decl id instead of name-strip — that is the **next** leftover bite, only fold it in if H6 is confirmed.

---

## 3. GREEN and verify

After a confirmed fix:

```text
Tools\RunBuild.ps1 -NoXGE ... -Label wave-b-packed-exec-build
Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen -Label wave-b-packed-exec-prod
Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST -Label wave-b-packed-exec-canonicalast
Tools\RunTests.ps1 -TestPrefix Angelscript.TestModule.AngelScriptSDK.Compiler -Label wave-b-packed-exec-compiler
```

Expect ProductionCodeGen **48/48** with execute 1934 and 902. CanonicalAST **321/321**. Compiler **511/511** (runner may `succeededWithWarnings=1`).

Must-stay-green: Isolated 4/4, Semantics 12/12, InitPlan 42, MemberRef 42, HostPick 42, switch 21/7, FValue Object 42, packed **opcode** WRTV1.

Append `attachments/wave-b-results.md`. **Leave 13.2 `[ ]`.** Do not uncheck 9.2.

---

## 4. Files

- Test: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` (`CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4`)
- Likely emit: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` (`EmitGeneratedAccessor` `:1106`, `EmitWriteValue`/`EmitReadValue`, `CopyVar`, `PushThisObject`, `FindFieldOffset` `:1320`)
- Do not edit `as_compiler.cpp`. Do not flip default CANONICAL.

---

## 5. Commands

From `D:\as-cta` only:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -ProjectFile D:\as-cta\AngelscriptProject.uproject -Label wave-b-packed-exec-build -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-packed-exec-prod -TimeoutMs 600000
```

Do not start Wave E–G. Do not archive. Do not commit.
