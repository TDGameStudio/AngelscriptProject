# Wave C debug tools — dump / verify printer inventory

> **Inventory only.** No fork/production edits. No UBT. Do not mark `tasks.md`. Implementation is a later exclusive-UBT TDD slice **after** C-28 (`wave-c-28-verifier-remainder.md`) so dump tests do not collide with `as_ast_verifier.cpp` / Verifier prefix.

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`. Package: **C-debug-tools** (`async-work.md` §8).

Clang `Stmt::dump()` / `dumpColor()` / `TextNodeDumper` is a **design reference only**. This project must not link Clang/LLVM, copy Clang headers, print arena pointers, or ship colored terminal dumps.

---

## Recommended first tool (implement later)

`asCASTFormatVerifyResult` in `as_ast_dump.*` (not `as_ast_verifier.cpp`). Observer-only. Formats `{category, range, detail}` that the verifier already returns. Does not change dump text, sidecar bytes, Cache, or Provider. Tests live on the existing Dump prefix.

Exact signature:

```cpp
// as_ast_dump.h — fork, no Unreal types
ANGELSCRIPTRUNTIME_API void asCASTFormatVerifyResult(const asSAstVerifyResult& result, asCString& out);
```

Stable grammar (address-free, one line, trailing newline):

```text
VERIFY category=<TOKEN> detail=<token> range=<fileID>:<begin>-<fileID>:<end>
```

`<TOKEN>` is the `asEASTVerifyCategory` enumerator without the `asAST_VERIFY_` prefix (`OK`, `DANGLING_ID`, `WRONG_KIND`, `UNSEALED_PUBLICATION`, …). Empty `detail` prints `detail=`. Invalid range prints `range=0:0-0:0`. Never `0x`.

Companion (same exclusive slice, after the formatter is green):

```cpp
ANGELSCRIPTRUNTIME_API void asCASTDumpOnVerifyFail(const asCASTContext& context, const asSAstVerifyResult& result, asCString& out);
```

- `category == asAST_VERIFY_OK` → formatter line only (no full dump).
- otherwise → formatter line, then `asCASTDump(context, dump)` appended.
- Seal (`as_ast_context.cpp:344`) currently discards `asSAstVerifyResult` and returns only `int`. Later callers / tests format locally. Do **not** change Seal’s return code in this package.

Lock it in `FCanonicalASTDumpTests` (`AngelscriptNativeCanonicalASTDumpTests.cpp`), prefix `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump`. Do **not** add these methods to Verifier tests (C-28 owns that file).

---

## 1. What dump already prints vs missing

Sources: `as_ast_dump.cpp` (dump `L77–234`, shadow `L252–302`), nodes in `as_decl.h` / `as_stmt.h` / `as_expr.h` / `as_ast_type.h`, verifier in `as_ast_verifier.h` (`asSAstVerifyResult`: `category`, `range`, `detail` — **no formatter**).

### 1.1 `asCASTDump` — already printed (address-free)

Header:

```text
AST
TU name=<translation-unit name>
```

| Line | Fields today |
| --- | --- |
| `DECL` | `id` `kind` (pretty name) `name` `parent` `key` (decl `stableKey`) `type` (**interned type `stableKey`**) `quals` `traits` `origin` `default` `deps` `bases` (decl ids) `span=<beginOffset>:<endOffset>` |
| `STMT` | `id` `kind`; **`target=<stmt id>` only when `stmt->target.IsValid()`** |
| `EXPR` | `id` `kind` `type=<interned type id, numeric>` `quals` `literal` `callee=<resolvedDecl stableKey or name>` |
| `EXPR` CALL/CONSTRUCT extra | `nargs` `args=<child literals, comma-joined>` `route=import` if `resolvedDecl` is `asAST_DECL_IMPORT` |

Kind pretty-names already include `MaterializeTemporary` and `Cleanup` (`as_ast_dump.cpp:71-72`). Sema stamps `literal=materialize` / `literal=cleanup` (`as_sema_lifetime.cpp:13,26`). CLEANUP `resolvedDecl`, when set, already appears as `callee=` (same path as every expr). CALL `literal` often contains `reverse-formal` (`as_sema.cpp:297`).

Identity: table ids and stable keys, never pointers. Dump tests, Standalone CanonicalAST, and sidecar encode all reject `0x`.

### 1.2 `asCASTDump` — missing (fields already on the graph)

These are **printer gaps**. Do not invent new POD fields to fill them.

| Topic | On the node today | Dump today | Gap |
| --- | --- | --- | --- |
| **resolvedDecl** | `asCExpr::resolvedDecl` | Pretty `callee=` if valid; empty `callee=` if not; no numeric decl id; no `resolved=` token | Cannot tell “unresolved” vs “resolved to a nameless decl”; CALL/CONSTRUCT without callee is **not** a dump or verifier requirement (hard no) |
| **cleanup / materialize** | Expr kinds + 1 child + optional CLEANUP `resolvedDecl` | Kind + `literal` + `callee=` if dtor found | No `children=` expr ids; no “this is a dtor” tag; MATERIALIZE `xvalue` not shown. **Do not** add stmt-level cleanup-plan fields (CLEANUP/MATERIALIZE already exist) |
| **stmt targets** | `asCStmt::target` | Printed only when valid (`target=%u`) | Continue/break tests in SemaAuthority already parse `target=` (`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:442`). Missing: `owner`, `children`, `expr`, `decl`, range/fileID; no target token when invalid |
| **type stableKey** | `asCType::stableKey`; DECL already prints it | EXPR prints **numeric** `type=%u` (`expr->type.type.value`) | EXPR cannot be grepped for `type=array<int>` (SemaAuthority array case hits the **DECL** line). No `TYPE` table. `asCASTContext` has no public `GetTypeCount()` |
| **value category** | `asCExpr::valueCategory` (`prvalue`/`lvalue`/`xvalue`); verifier already rejects illegal values (`expr-value-category`) | **Never printed** | Clang `TextNodeDumper` prints value kind; we should print `vc=prvalue\|lvalue\|xvalue` later, without color |

Also not dumped (reconstruction holes, not first-tool): decl `children` / `body`; stmt child lists (If/While/Switch tree is invisible); expr operand ids except CALL/CONSTRUCT **literals**; range `fileID`; sealed flag.

### 1.3 `asCASTShadowDiff` — already printed vs missing

Already: `"match"` or `"mismatch"` plus space-separated **decl-table** tokens in index order: `count` `owner` `type` `trait` `source` `dependency`. Locked by `FCanonicalASTShadowTests` (`Frontend.CanonicalAST.Shadow`).

Missing (decl-only by design today): stmt/expr/type tables, `resolvedDecl`, value category, stmt targets, children, names/keys, cleanup/materialize. Do **not** expand ShadowDiff in the first debug slice; SemaAuthority and Dump already lock body facts.

### 1.4 Verifier / Seal — no printer

`asSAstVerifyResult` (`as_ast_verifier.h:9-16`) is `{category, range, detail}`. `Fail()` writes those three fields. There is **no** `asCASTFormatVerifyResult`. Tests compare `Result.detail.Equals("expr-id")` etc.

`asCASTContext::Seal()` (`as_ast_context.cpp:344-358`) calls `asCASTVerify`, then **drops** `result` and returns `(int)category`. Seal failures are an `int`. That is the Seal-diagnostic hole the formatter closes.

`asCASTVerifyPublication` is still C-28 (not landed in the fork header at inventory time). Formatter must accept every existing `asEASTVerifyCategory`, including `UNSEALED_PUBLICATION`, without requiring that API.

### 1.5 Existing tests that already use dump as an oracle

| Prefix / file | What it locks |
| --- | --- |
| `Frontend.CanonicalAST.Dump` — `AngelscriptNativeCanonicalASTDumpTests.cpp` | Byte-identical dumps, no `0x`, `DECL id=2 kind=Function name=F` (**1 method**) |
| `Frontend.CanonicalAST.Shadow` | ShadowDiff tokens; left dump still has `deps=Other` |
| `Frontend.CanonicalAST.BodySema` / `Sema` | Kind names; `reverse-formal`; `MaterializeTemporary` / `Cleanup` |
| `Compiler.CanonicalAST.SemaAuthority` (22/22) | `callee=` / `key=` / `nargs` / `args=` / `target=` / `route=import` / `type=array<int>` on DECL |
| Standalone CanonicalAST | Deterministic dump, no `0x` |
| `Cache.ASTBodySidecar` / HotReload snapshot | `asCASTRejectNonSidecarInput` rejects raw `AST\n` as Cache/Provider input |

Dump **prefix** is the right lock for a new printer. Do not open a second Native SDK debug class unless Dump tests overflow.

---

## 2. Helper: exact API, tests, observer rules

### 2.1 Headers / files

| Path | Change (later exclusive UBT) |
| --- | --- |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.h` | Declare formatter + dump-on-verify-fail. Include `as_ast_verifier.h`. No UE types. |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_dump.cpp` | Implement both. Local `VerifyCategoryName()` switch. |
| `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTDumpTests.cpp` | Two new methods; keep `RepeatedBuildsDumpIdenticallyWithoutPointers` |
| `as_ast_verifier.*` | **Do not touch** (C-28) |
| `as_ast_sidecar.cpp` | **Do not touch** (Wave F). Must not start hashing/decoding dump text |

`as_ast_dump.h` includes verifier; verifier must **not** include dump.

### 2.2 Formatter implementation sketch (later)

```cpp
void asCASTFormatVerifyResult(const asSAstVerifyResult& result, asCString& out)
{
	const char* category = VerifyCategoryName(result.category);
	const char* detail = result.detail.AddressOf() ? result.detail.AddressOf() : "";
	out.Format("VERIFY category=%s detail=%s range=%u:%u-%u:%u\n",
		category,
		detail,
		result.range.begin.fileID,
		result.range.begin.offset,
		result.range.end.fileID,
		result.range.end.offset);
}

void asCASTDumpOnVerifyFail(const asCASTContext& context, const asSAstVerifyResult& result, asCString& out)
{
	asCASTFormatVerifyResult(result, out);
	if( result.category == asAST_VERIFY_OK )
	{
		return;
	}
	asCString dump;
	asCASTDump(context, dump);
	out += dump;
}
```

`VerifyCategoryName` covers every enumerator in `as_ast_kind.h:99-110`. Unknown byte → `UNKNOWN` (still no pointer).

### 2.3 Tests that lock it

Append inside `FCanonicalASTDumpTests` (same flags/prefix). Hand-build `asSAstVerifyResult`; do **not** depend on C-28-only detail tokens being produced by `asCASTVerify` (you may still *format* `cleanup-dtor` as a string).

```cpp
	TEST_METHOD(FormatVerifyResultIsAddressFreeAndStable)
	{
		asSAstVerifyResult Result;
		Result.category = asAST_VERIFY_WRONG_KIND;
		Result.detail = "cleanup-dtor";
		Result.range.begin = asCSourceLocation(1, 4);
		Result.range.end = asCSourceLocation(1, 8);
		asCString Text;
		asCASTFormatVerifyResult(Result, Text);
		const FString Line = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
		ASSERT_THAT(IsTrue(Line.Equals(TEXT("VERIFY category=WRONG_KIND detail=cleanup-dtor range=1:4-1:8\n")),
			TEXT("formatter grammar must be stable and address-free")));
		ASSERT_THAT(IsTrue(!Line.Contains(TEXT("0x")), TEXT("formatter must not spell pointers")));
	}

	TEST_METHOD(DumpOnVerifyFailIncludesVerifyLineAndAstDump)
	{
		asCASTContext Empty;
		asSAstVerifyResult Result;
		ASSERT_THAT(AreEqual((int)asAST_VERIFY_DANGLING_ID, asCASTVerify(Empty, Result),
			TEXT("empty context is the existing dangling-TU case")));
		asCString Text;
		asCASTDumpOnVerifyFail(Empty, Result, Text);
		const FString Combined = AngelscriptNativeTestSupport::CanonicalAstDumpToFString(Text);
		ASSERT_THAT(IsTrue(Combined.StartsWith(TEXT("VERIFY category=DANGLING_ID detail=translation-unit")),
			TEXT("fail path must lead with the formatter line")));
		ASSERT_THAT(IsTrue(Combined.Contains(TEXT("\nAST\n")), TEXT("fail path must append asCASTDump")));
		ASSERT_THAT(IsTrue(!Combined.Contains(TEXT("0x")), TEXT("combined dump must stay address-free")));
	}
```

OK path (optional third method, same class): `asCASTDumpOnVerifyFail` on a sealed DumpMod sample emits **only** `VERIFY category=OK detail= range=0:0-0:0\n` and must **not** contain `DECL`.

Seal wiring is **not** in this first tool. Tests format `asSAstVerifyResult` themselves. A later one-line Seal change may call `asCASTDumpOnVerifyFail` into an `asCString` diagnostic sink; it must not change the `int` Seal returns.

### 2.4 Dumps must NEVER become Cache / Provider input

Already true at the reject gate:

- `asCASTRejectNonSidecarInput` treats leading `AST\n` as `asAST_SIDECAR_UNSUPPORTED_INPUT` (`as_ast_sidecar.cpp:380-382`).
- Cache `OldSchemaDumpAndHirInputsAreSafeMisses` and HotReload snapshot tests lock that.
- Specs: `as-primary-engine-typed-ast-generate` “AST dump is separate from artifact generation”; `as-incremental-script-cache` dump files are not persistence inputs; `static-jit-diagnostics` dump must not claim Provider generation.

Known Wave F debt (do **not** “fix” in this package): `asCASTEncodeSidecar` **embeds** `asCASTDump` text plus a decl table (`as_ast_sidecar.cpp:69-107`). Decode **ignores** the dump. That is why the first debug tool is a **new formatter**, not a dump-format change: adding EXPR `vc=` / `typeKey=` would churn sidecar bytes until Wave F stops encoding dump.

Rules for this package:

- Do not feed dump or formatter output into Cache DTO, Provider, `contentHash`, or ExactStartup.
- Do not make `asCASTDecodeSidecar` parse dump text.
- Keep `asCASTRejectNonSidecarInput('AST\n')` green.
- `CollectFunctionRecords` already hashes decl facts, not dump — leave it.

---

## 3. What must wait until after C-28 (2.8 remainder)

C-28 exclusive UBT owns `as_ast_verifier.cpp` / `as_ast_verifier.h` / `AngelscriptNativeCanonicalASTVerifierTests.cpp`. One UBT user. Dump implementation shares the plugin DLL.

**Wait (do not implement now):**

| Item | Why after 2.8 |
| --- | --- |
| Any edit to `as_ast_dump.*`, Dump tests, or `as_ast_context::Seal` | Exclusive UBT; Dump prefix is part of Frontend CanonicalAST which C-28 re-runs as GREEN |
| Dump field expansion (`vc=`, EXPR `typeKey=`, stmt `children=` / `owner=` / `expr=`) | Churns SemaAuthority/BodySema `Contains()` oracles **and** sidecar-embedded dump bytes |
| Formatter tests that **require** `asCASTVerify` to emit `cleanup-dtor` / `stmt-multi-owner` / `unsealed-publication` | Those tokens are C-28 close criteria. Formatter tests must hand-build `asSAstVerifyResult` instead |
| `asCASTVerifyPublication` in dump-on-fail fixtures | Header not landed until C-28 |
| ShadowDiff stmt/expr expansion | Not needed for Seal diagnostics; collides with verifier stmt-parent work |
| TYPE table dump / public `GetTypeCount()` | Better with 2.6 named type keys; needs a context API |
| Wave D `Build()` routing, Ready, default CANONICAL | Hard no until after 2.8 + R09 |

**Do not wait on (already true, inventory only):** Clang dump as a design reference; Cache `AST\n` reject tests; existing Dump identity test.

Stale: `execution-plan.md` §2 task 2.8 lists `as_ast_dump.*` beside verifier. Live order is `async-work.md`: C-28 verifier first, dump printer after.

---

## 4. Later exclusive-UBT TDD steps (from `D:\as-cta`)

Gate: C-28 reports Verifier + Frontend CanonicalAST + BodySema + CodeGen green **without** CALL-without-callee. If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are live, wait. `-NoXGE`. Do not start a second build.

### Step 1 — RED formatter tests (no fork behavior yet)

Add the two Dump methods above. Do not edit `as_ast_dump.cpp` yet (link/compile fail on missing symbols is an acceptable first RED; add empty declarations only if the test file must compile).

```powershell
Set-Location D:\as-cta
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-debug-red -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump" -Label wave-c-debug-red -TimeoutMs 600000
```

Expected: new methods RED; `RepeatedBuildsDumpIdenticallyWithoutPointers` still PASS once the binary links.

### Step 2 — GREEN formatter + dump-on-fail

Implement `asCASTFormatVerifyResult` and `asCASTDumpOnVerifyFail` in `as_ast_dump.*` only.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-debug-green -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump" -Label wave-c-debug-green -TimeoutMs 600000
```

Expected: Dump prefix all PASS (old 1 + 2 new).

### Step 3 — Frontend CanonicalAST regression (dump oracles unchanged)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-c-debug-frontend -TimeoutMs 600000
```

Expected: previous Frontend count + 2 Dump methods. SemaAuthority/BodySema dump `Contains()` still green because dump **text did not change**.

Optional Cache reject (only if sidecar/dump files were touched — they should not be):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Cache.ASTBodySidecar" -Label wave-c-debug-cache-miss -TimeoutMs 600000
```

### Step 4 — additive dump fields (separate exclusive slice, after Step 3)

Only **append** tokens; do not reorder existing `DECL`/`STMT`/`EXPR` keys (SemaAuthority greps `callee=` `target=` `type=array<int>` `nargs=`).

Suggested EXPR suffix: `vc=prvalue|lvalue|xvalue` and `typeKey=<stableKey>` while keeping numeric `type=%u`. Suggested STMT suffix: `owner=` `expr=` `decl=` `children=` (comma ids). CLEANUP already has `callee=` when `resolvedDecl` is a dtor; do not add a cleanup-plan field.

Re-run Dump then full Frontend CanonicalAST. If sidecar bytes change, that is Wave F debt — do not teach Cache to parse the new text.

### Step 5 — optional Seal diagnostic (tiny, after Step 2)

`Seal()` may format fail into a local `asCString` for test assertion helpers only. Must still return the same `int`. No UE types. No debugger UI.

Do **not** check `tasks.md` 2.8 / 13.5 / 13.2 / 5.9 from dump greens.

---

## 5. Explicit non-goals

- Colored terminal dumps (`Stmt::dumpColor`, `ASTDumperUtils.h` `ValueKindColor` / `AddressColor`). Adopt type + value kind + resolved target **as tokens**, not ANSI.
- Shipping a debugger UI, DAP changes, or VS Code dump viewer.
- Inventing stmt/expr cleanup-plan POD fields. CLEANUP / MATERIALIZE are expr kinds (`async-work.md` §3).
- CALL/CONSTRUCT-without-callee as a seal, dump, or verifier firewall (reverted hard no).
- Linking Clang/LLVM, copying `TextNodeDumper`, pretty-printing source (`dumpPretty`).
- Making dump or formatter output a Cache DTO, Provider file, sidecar `contentHash`, or ExactStartup input.
- Changing `asCASTVerify` to fail unsealed graphs (`Seal()` calls it before `sealed = true`).
- Expanding `asCASTShadowDiff` in the first slice.
- Routing production `Build()`, flipping Ready/default CANONICAL, or marking 13.2 / 5.9 from dump greens.
- Unreal types in `as_ast_*` / `as_sema*` / `as_bytecode_codegen` / `as_source_manager`.

---

## Clang mapping (design reference only)

| Clang (`Reference/llvm-project`, not a dependency) | Adopt | Exclude |
| --- | --- | --- |
| `Stmt::dump()` / `dump(raw_ostream, ASTContext)` | Observer dump of a sealed graph | `llvm::errs()`, `raw_ostream` |
| `dumpColor()` + `ASTDumperUtils.h` colors | — | All terminal color |
| `TextNodeDumper`: type, value kind, named Decl | `typeKey=`, `vc=`, `callee=` / later `resolved=` | Pointer addresses, tree-indent `\|-` art |
| `dumpPretty` / `printPretty` | — | Source reprint |
| `ExprWithCleanups` / `MaterializeTemporaryExpr` | Already explicit expr kinds | New cleanup-plan structs |

Our dump stays a **flat address-free table** (`AST` / `DECL` / `STMT` / `EXPR` lines). That is already the right shape for determinism tests. The missing Clang-shaped facts are value category, expr type key, and a verify-result line — not a second dump language.

---

## Close criteria (later implementation, not this inventory)

May land the first debug tool when:

- [ ] `asCASTFormatVerifyResult` matches the grammar above; no `0x`; no UE types
- [ ] `asCASTDumpOnVerifyFail` prefixes that line and appends `asCASTDump` only on failure
- [ ] Dump prefix tests lock both; existing Dump identity test still PASS
- [ ] Frontend CanonicalAST dump oracles unchanged (no silent format churn)
- [ ] `asCASTRejectNonSidecarInput('AST\n')` still `UNSUPPORTED_INPUT`
- [ ] `as_ast_verifier.cpp` untouched in that slice
- [ ] No CALL-without-callee; no cleanup-plan POD; no colored dump; no Cache/Provider input path
