# Wave B queued exclusive UBT — tenth-pass F3 exact layout / CopyVar / LoadReturn width

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-abi-width-next**. **Research only in this dispatch.** Do not UBT. Do not implement. Do not edit `Plugins/`, `tasks.md`, `async-work.md`, `async-dispatch.md`.

Companions: `attachments/async-work.md` §3 F3 / 9.2; `reviews/implementation-rereview-2026-08-22-tenth-pass.md` F3; `attachments/wave-b-tenth-f2-wire.md` (holds the UBT mutex now).

LLVM/Clang is a **shape** reference only. Do not link. No Unreal types in fork frontend files.

This bite is **not** a 9.2 / 9.5 / 5.4 / 5.8 / 13.2 close. Do not check those boxes because this file exists, because RED tests exist, or because the later exclusive UBT goes GREEN. Do **not** uncheck 9.2 (虚标 stays `[x]` until an explicit rereview pass).

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Queued exclusive-UBT TDD map. One bite. Implement **after** F2 mutex releases |
| Gate | Isolated traces GREEN (`wave-b-54-remain-iso2` **4/4**, Semantics **12/12**). Those greens do **not** close F3 |
| Do not mark | **9.2 / 9.5 / 5.8 / 13.2** (or 5.4 / 4.2 / 9.1 / 10.2) |

---

## 0. Honest: Isolated 12/12 does not close 9.2

`tasks.md` 9.2 is already `[x]`:

> Implement local/parameter/global reads/writes, literals, exact conversions, scalar/enum unary/binary/logical/comparison operations, assignments/mutations, and return-value marshalling from canonical expressions.

That checkbox is **虚标**. Tenth-pass F3: return-slot plus 4-or-8 `CopyVar` / `LoadReturn` / `EmitReadValue` / `EmitWriteValue` is a **scalar subset**, not exact-width ABI.

What Isolated **4/4** + Semantics **12/12** actually proved:

| Fixture | Width it exercises | Why it cannot close 9.2 |
| --- | --- | --- |
| Logical `&&` / `\|\|` traces | `int` / `bool` stack slots (1 dword) | `CopyVar(..., 1)` → `CpyVtoV4` is the correct 4-byte stack move |
| Conditional mismatched arms | `int` / `float` | Same 4-byte (or float) slots |
| Property `GetValue` / `SetValue` + `Stored` | `int` (4 bytes) | `WRTV4` / `RDR4` happen to match the field |
| `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` | `struct FValue { int Value = 41; }` | Return is `int`. Member is 4 bytes at offset 0. `returnSlot` + `CpyVtoV4` / `CpyVtoR4` is enough |
| Index write-through | `array<int>` | 4-byte payload |

`returnSlot` (`Emit()` allocates a function-wide slot, `STMT_RETURN` copies into it, epilogue `DestroyLiveObjects` skips it, then `LoadReturn`) is the right **lifetime** patch for “dtor CALL clobbers the value register”. It is **not** a width/layout layer.

9.2’s words include **exact** conversions and return-value marshalling. Current CodeGen has only:

```text
dwords >= 2 → 8-byte instruction
otherwise   → 4-byte instruction
```

So 1-byte and 2-byte members are written with `WRTV4`, and anything whose dword count is `>= 2` is copied with an 8-byte op (3-dword / 12-byte values lose the tail). Isolated int traces never enter those branches as a mismatch.

**This dispatch does not uncheck 9.2.** Record honesty here. Checkbox surgery waits for rereview.

---

## 1. Live file:line — 4-byte vs 8-byte branches and silent hazards

File: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp`.

Line numbers are a **2026-08-22 snapshot before F2 wire**. F2 exclusive UBT edits this same file; implementer must **re-grep the helper names**, not trust these numbers after that mutex.

### 1.1 The two-way helpers (every payload becomes 4 or 8)

```589:611:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		void EmitReadValue(int dest, int dwords)
		{
			if( dwords >= 2 )
			{
				bc.InstrSHORT(asBC_RDR8, (short)dest);
			}
			else
			{
				bc.InstrSHORT(asBC_RDR4, (short)dest);
			}
		}

		void EmitWriteValue(int src, int dwords)
		{
			if( dwords >= 2 )
			{
				bc.InstrSHORT(asBC_WRTV8, (short)src);
			}
			else
			{
				bc.InstrSHORT(asBC_WRTV4, (short)src);
			}
		}
```

`ValueDwords` / `SizeDwords` feed these. For `int8` / `uint8` / `int16` / `uint16` / `bool`, `GetSizeInMemoryDWords()` is **1** (`as_datatype.cpp:720-731`: `s <= 4` → 1 dword). So every sub-4-byte **memory** write is `WRTV4`.

```1070:1092:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
		void CopyVar(int dest, int src, int dwords)
		{
			if( dwords >= 2 )
				bc.InstrW_W(asBC_CpyVtoV8, dest, src);
			else
				bc.InstrW_W(asBC_CpyVtoV4, dest, src);
		}

		void LoadReturn(int src, int dwords)
		{
			if( dwords >= 2 )
				bc.InstrSHORT(asBC_CpyVtoR8, (short)src);
			else
				bc.InstrSHORT(asBC_CpyVtoR4, (short)src);
		}

		void StoreReturn(int dest, int dwords)
		{
			if( dwords >= 2 )
				bc.InstrSHORT(asBC_CpyRtoV8, (short)dest);
			else
				bc.InstrSHORT(asBC_CpyRtoV4, (short)dest);
		}
```

`dwords >= 2` collapses **3, 4, …** dwords into one 8-byte copy. A 12-byte VALUE local (`GetSizeInMemoryDWords()==3`) is truncated, not copied.

`PushValue` (`:1379-1385`) is the same 4-or-8 split (`PshV8` / `PshV4`). Not this bite’s execute fixture.

### 1.2 Hardcoded `WRTV4` that does not even look at size

These ignore `ValueDwords` entirely:

| Site (snapshot) | Function | What it does |
| --- | --- | --- |
| `:1499` | `EmitAssign` this-property `DECL_REF` | `WRTV4` after `ADDSi` |
| `:1519` | `EmitAssign` this-property via `lhs->literal` | `WRTV4` after `ADDSi` |
| `:1903` | `EmitMemberStore` | `WRTV4` after `ADDSi` **always** |
| `:1281` | `StoreGlobal` | `LDG` + `WRTV4` (globals are not packed neighbors; still wrong for `int8` global *value*, but production mutable globals are rejected) |

`EmitMember` load (`:1875-1879`) duplicates `EmitReadValue`’s 4-or-8 (`RDR8` / `RDR4`) instead of calling it.

Reference payload (`:1448-1451`, `:1568-1571`): `GetSizeInMemoryDWords() >= 2` → 8 else 4. `int8 &` is 4-byte `RDR4`/`WRTV4` into the pointed object.

### 1.3 Callers that inherit the 4-or-8 lie

| Site | Caller | Hazard |
| --- | --- | --- |
| `:816` | `EmitConstructorMemberDefaults` | `EmitWriteValue(dest, dwords)` into property. Integer member defaults are F1 (`atoi`); still 4-or-8 if this bite leaves the helper unchanged |
| `:856` / `:885` | `EmitGeneratedAccessor` | Get: `EmitReadValue`; Set: `EmitWriteValue`. Generated `SetB(int8)` today `WRTV4`s into neighbors |
| `:1428` | `EmitDeclRef` this-member load | `EmitReadValue` — `RDR4` of `int8` is wider than the field (reads neighbor bytes into the local). VM `RDR1` zeros the rest of the dword (`as_context.cpp:3114-3123`) |
| `:1640` | `EmitAssign` index | `EmitWriteValue(rhs, payloadDwords)` — `array<int8>` would smash the next element; **out of this bite** (needs F2 bind + array) |
| `:1708` | `EmitListFactoryInto` | `EmitWriteValue(args[i], elemDwords)` while `ListElementBytes` already knows exact bytes (`:630-641`). Double list already locks `WRTV8`; `int8` list would `WRTV4` |
| `:1945` / `:2014` | `EmitIndex` | `EmitReadValue` |
| `:2521` + `:505` | `STMT_RETURN` + epilogue | `CopyVar(returnSlot, value, returnDwords)` then `LoadReturn`. Fine for Isolated `int`. Truncates `>8` value returns |

### 1.4 Contrast: CodeGen already has exact-width **immediates**

`SetConst` (`:1094-1105`) already switches on `GetSizeInMemoryBytes()`: `SetV1` / `SetV2` / `SetV4` / `SetV8`. Memory R/W did not follow.

LEGACY `asCCompiler` already emits exact memory ops (`as_compiler.cpp:10476-10484` assign-to-ref; `:20303-20310` read-from-ref; `:3836-3853` struct member zero; `:10520` / `:10552` `asBC_COPY` with **byte** size for POD). This bite copies that contract into CodeGen helpers, not the whole compiler.

### 1.5 Why packed `int8` smash is deterministic (not Isolated’s uninit-local flake)

VM `SetV1` writes the **full dword argument** into the stack slot (`as_context.cpp:3582-3591`). Encoder `InstrSHORT_B` zero-fills the other three bytes (`as_bytecode.cpp:2707-2711`). So `p.B = 9` materializes slot bytes `09 00 00 00`.

`WRTV4` copies those 4 bytes to `valueRegister` (`as_context.cpp:3104-3106`).

Layout of

```angelscript
struct Packed
{
    int8 A;
    int8 B;
    int8 C;
    int8 D;
}
```

`int8` alignment is 1 (`as_datatype.cpp:757-758`). Both `as_builder.cpp:4164-4171` and CodeGen `RegisterCanonicalScriptTypes` (`:2885-2892`) pack `A@0 B@1 C@2 D@3`. CodeGen then pads `st->size` to `st->alignment` (`:2898-2901`; alignment forced to 4 at `:2842`, then `AddPropertyToClass` may bump it). Size 4. Neighbors share the first dword.

After `A=1 B=2 C=3 D=4`, `B=9` with `WRTV4` at offset 1 writes `09 00 00 00` onto bytes 1–4 → **C and D become 0**. Result `1900`. LEGACY `WRTV1` writes one byte → **1934**.

`SetV1` zero-extension makes this **stable**, unlike tenth-pass `FValue().Value` depending on leftover stack (`got=13733`). Do not “fix” the fixture by adding `= 41` member initializers (that is F1 `atoi` / InitPlan).

### 1.6 Silent `>8` / `<4` summary

| Input | Today | Correct |
| --- | --- | --- |
| 1-byte property/member/index/list element | `WRTV4` / `RDR4` | `WRTV1` / `RDR1` |
| 2-byte | `WRTV4` / `RDR4` | `WRTV2` / `RDR2` |
| 4-byte | `WRTV4` / `RDR4` / `CpyVtoV4` | same |
| 8-byte (`int64` / `double`) | `WRTV8` / `RDR8` / `CpyVtoV8` when `dwords>=2` | same (already locked by ProductionCodeGen int64/double accessor tests) |
| 3 dwords / 12-byte VALUE | `CpyVtoV8` / `WRTV8` — **truncate** | `asBC_COPY` with **byte** size, or **fail-closed** |
| 0 / unknown | `dwords < 1` forced to 1 → `WRTV4` | fail-closed |

---

## 2. Exact next TDD bite (ONE bite)

Not the lifetime matrix. Not handle/refcount. Not 12-byte `COPY` as a success path. **Packed VALUE POD neighbor smash + opcode lock on the store.**

### 2.1 Why this fixture, not 12-byte, not Isolated int again

- Adjacent-field smash is observable **execute** RED with a known `1900` vs `1934`.
- It hits `EmitMemberStore` `:1903` and/or generated `EmitWriteValue` — the actual F3 bug Isolated int never touches.
- A 12-byte `dst = src` GREEN would require `asBC_COPY` + `asOBJ_POD` (CodeGen **never sets** `asOBJ_POD` today, `:2829-2832`). That is a **second** production change. This bite’s rule for unsupported sizes is **fail-closed**, not “implement COPY now”.
- `int16` pair (`Lo@0 Hi@2`) is the same helper (`WRTV2`). Include it as a second function on the **same Isolated method** so GREEN cannot be “special-case int8 only”.

### 2.2 Tests to add (smallest set)

**Do not weaken** existing Isolated `int` traces or ProductionCodeGen int64/double `RDR8`/`WRTV8` rows.

#### Test A — Isolated execute (required)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp`

New method: `IsolatedPackedInt8Int16NeighborWriteMatchesLegacyCanonical`

Pattern: copy `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` (`:597-681`): **two engines**, same source, assert publisher `COMPILER` vs `CANONICAL_CODEGEN`. **No `Trace`.** No user ctor/dtor. No member initializers. No `@`. No script `funcdef`. No `array`.

Inline AS (`ASTEST_AS_ANSI`, Allman, `Documents/Rules/ASInlineFormattingRule.md`):

```angelscript
struct Packed
{
    int8 A;
    int8 B;
    int8 C;
    int8 D;
}

struct Pair16
{
    int16 Lo;
    int16 Hi;
}

int RunPacked()
{
    Packed p;
    p.A = 1;
    p.B = 2;
    p.C = 3;
    p.D = 4;
    p.B = 9;
    return int(p.A) * 1000 + int(p.B) * 100 + int(p.C) * 10 + int(p.D);
}

int RunPair16()
{
    Pair16 p;
    p.Lo = 1;
    p.Hi = 2;
    p.Lo = 9;
    return int(p.Lo) * 100 + int(p.Hi);
}
```

Oracles **on both engines**:

| Check | LEGACY | CANONICAL today (RED) | GREEN |
| --- | --- | --- | --- |
| `Packed` offsets | `B==1 C==2 D==3` (query `asITypeInfo` properties after Build) | same pack (`RegisterCanonicalScriptTypes` already packs) | still packed; **do not** “fix” by aligning int8 to 4 |
| `RunPacked()` | `1934` | `1900` (`WRTV4` at `B@1` zeros C,D) or `Build()!=0` | `1934` |
| `RunPair16()` | `902` | `900` (`WRTV4` at `Lo@0` zeros `Hi`) or `Build()!=0` | `902` |
| Publisher | `asBYTECODE_PUBLISHER_COMPILER` | `CANONICAL_CODEGEN` if Build succeeded | `CANONICAL_CODEGEN` |

Layout query (do not skip): after Build, `GetTypeInfoByName("Packed")` / `"Pair16"` and read `asCObjectProperty::byteOffset` (or `asITypeInfo::GetProperty` offset out-param). If CANONICAL ever dword-aligns members, execute `1934` would be a **false green** with `WRTV4` still in the stream.

Do **not** rewrite `p.B = 9` to explicit `GetB`/`SetB`. LEGACY `propertyAccessorMode==0` compiles direct member stores. If CANONICAL property-rewrite turns the store into generated `SetB`, smash still happens inside `EmitWriteValue`; keep the source as member assigns so LEGACY stays a real `WRTV1` oracle.

#### Test B — opcode / layout lock (required, same bite)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`

New method: `CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4`

CANONICAL-only Engine. Same `Packed` + `RunPacked` script (module name e.g. `ProdPackedInt8Width`). Follow `CanonicalGeneratedInt64AccessorUsesRdr8NotRdr4` (`:1401-1460`).

Assert:

1. `Build()==0`, publisher `CANONICAL_CODEGEN`.
2. `Packed` offsets `B==1 C==2 D==3`.
3. The **store instruction** is 1-byte:
   - If generated `SetB` exists: `ContainsOpcode(SetB, asBC_WRTV1)` and **not** `asBC_WRTV4` (mirror int64’s `WRTV8` and not-`WRTV4`).
   - Else `RunPacked` bytecode contains `asBC_WRTV1` and does not contain `asBC_WRTV4`.
4. Execute `RunPacked()==1934`.

Optional same method or a 4-line sibling for `Pair16` / `SetLo`: `WRTV2`, not `WRTV4`. Prefer one method with both structs if it stays short.

**Do not** assert `asBC_COPY`. **Do not** add a 12-byte execute-success row in this bite.

### 2.3 Expected RED today

No UBT was run in this research dispatch. RED is from the live helpers + VM semantics above, not from a saved report.

| Method | Likely RED |
| --- | --- |
| `IsolatedPackedInt8Int16NeighborWriteMatchesLegacyCanonical` | LEGACY `1934` / `902`. CANONICAL `RunPacked` `1900`, `RunPair16` `900`. Offsets already packed, so this is width, not layout-registrar |
| `CanonicalPackedInt8MemberStoreUsesWrtv1NotWrtv4` | `SetB` or `RunPacked` contains `WRTV4`; execute `1900` |

If CANONICAL `Build()!=0` on this script (missing generated ctor, etc.), that is still RED vs LEGACY. Do not retcon the script into Isolated’s `int Value = 41` user-ctor shape.

TDD: add the tests **first**, run them, confirm RED, then change CodeGen.

### 2.4 GREEN production change (only this)

One memory-move helper keyed on **`GetSizeInMemoryBytes()`**, not dword count:

```text
bytes == 1 → WRTV1 / RDR1
bytes == 2 → WRTV2 / RDR2
bytes == 4 → WRTV4 / RDR4
bytes == 8 → WRTV8 / RDR8
else       → FailAt(__LINE__, asNOT_SUPPORTED)
             // NEVER WRTV4 into a neighbor
             // NEVER CpyVtoV8 / WRTV8 a 12-byte payload
```

Wire it through:

1. `EmitReadValue` / `EmitWriteValue` (change signature to bytes, or look up type at the call site).
2. `EmitMemberStore` — **delete** hardcoded `WRTV4` at `:1903`.
3. `EmitAssign` this-property `:1499` and literal `:1519` — **delete** hardcoded `WRTV4`; call the helper.
4. `EmitMember` load `:1875-1879` — call `EmitReadValue` (or the helper); do not keep a second 4-or-8 fork.
5. Reference `RDR*` / `WRTV*` in `EmitDeclRef` / `EmitAssign` (`:1448-1451`, `:1568-1571`) — same byte switch.

`CopyVar` / `LoadReturn` / `StoreReturn` for **primitive stack slots** may stay 4/8: Isolated `int` / `int64` live in dword-aligned frame slots. **Do not** use them for in-object field stores.

If `CopyVar` is given `dwords > 2` (12-byte VALUE local assign), **fail-closed** this bite. Do not silently `CpyVtoV8`. Do not implement `asBC_COPY` here.

`SetConst` is already exact; do not rewrite it.

Fail-closed on `int8` is **wrong** — `int8` is supported. Fail-closed is for sizes outside `{1,2,4,8}`.

Do not pad `int8` members to 4 bytes in `RegisterCanonicalScriptTypes` to make `WRTV4` accidentally safe. Offsets in Test A/B forbid that cheat.

---

## 3. What NOT to fold into this bite

| Out | Why |
| --- | --- |
| F2 exact bind | Another agent owns exclusive UBT (`wave-b-tenth-f2-wire.md`). Do not start this bite until that mutex is free |
| Handle AddRef / `REFCPY` / funcdef copy | 9.5 remainder; Isolated packed fixture is VALUE POD, no handles, no `@` |
| Full cleanup plans / `as_sema_lifetime` | 5.8. No stmt-level cleanup POD |
| Detached artifact / atomic `Commit` | 9.1 / 13.6 / F7. Do not retouch `as_module.cpp` `InternalReset` |
| Typed InitPlan / `atoi` member defaults | F1 / 5.7 / 5.8 (`wave-b-initplan-next.md`). Fixture has **no** `= 41` |
| `asBC_COPY` 12-byte / `asOBJ_POD` flag | Next exclusive after this GREEN. This bite fail-closes `>8` |
| Index / `array<int8>` smash | Needs F2 native bind + `opIndex`. Silent `EmitWriteValue` on index stays documented, not this RED |
| `StoreGlobal` `WRTV4` | Production mutable globals already reject. Not a packed-neighbor smash |
| Verifier CALL-without-callee | F6. Never on unsealed `asCASTVerify` |
| Default CANONICAL / `CompileFunction` | Wave G / mixed COMPILER |
| Uncheck or check **9.2 / 9.5 / 5.8 / 13.2** | Honesty only |

Queued **after** this bite GREEN (not this mutex): 12-byte POD `dst = src` execute `123` via `asBC_COPY` byte size, matching LEGACY `:10520`. That is when CopyVar stops being “4-or-8 or fail”.

---

## 4. Commands later UBT would use

Only from `D:\as-cta`. Always `-NoXGE` on build. `RunTests.ps1` does **not** UBT — `RunBuild.ps1` first after impl. Never All. Never `UnrealEditor-Cmd` direct.

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-abi-width -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-abi-width-iso -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-abi-width-prod -TimeoutMs 600000
```

TDD order:

1. Add Test A + Test B only. Build. Run those prefixes. Confirm RED (`1900` / `WRTV4`).
2. Implement the helper + delete hardcoded `WRTV4` stores. Build. Same prefixes GREEN (`1934` / `902` / `WRTV1`).
3. Must-stay-green: existing Isolated **4/4**, Semantics **12/12**, ProductionCodeGen named rows including int64/double `RDR8`/`WRTV8`. Do not rerun All.

If UBT says up to date while `as_bytecode_codegen.cpp` changed (often plugin git `??`): delete `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` and `Intermediate/.../AngelscriptRuntime/Module.AngelscriptRuntime*.obj`, then rebuild. Same force-rebuild note as F2.

One UBT user in `D:\as-cta`. Do not start while **B-tenth-f2-wire** holds the mutex.

---

## 5. Stay-unchecked / stay-checked

Leave `[ ]`: **9.5 / 5.8 / 13.2 / 5.4 / 9.1 / 10.2**.

Leave already-checked 虚标 **9.2** as `[x]` — this bite does not reopen the box and does not make the spec sentence true. Exact-width packed stores are a **slice** of 9.2, not the full local/global/conversion/marshalling matrix.

Do not archive. Do not commit unless asked. Default pipeline stays LEGACY.
