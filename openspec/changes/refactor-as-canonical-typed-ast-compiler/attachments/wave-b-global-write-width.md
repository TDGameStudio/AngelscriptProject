# Wave B: global writes use the canonical value-width ABI

Date: 2026-08-23  
Worktree: `D:\as-cta`

## Problem

Canonical CodeGen had one exceptional write path:

```cpp
LDG <global-address>
WRTV4 <source>
```

`StoreGlobal` ignored its sealed `asCDataType` and always used `asBC_WRTV4`.
That disagreed with member writes, index writes, generated setters, and list-pattern
buffer writes, which already route through `EmitWriteValue` and select `WRTV1`,
`WRTV2`, `WRTV4`, or `WRTV8` from the value's memory width.

The bug corrupts adjacent memory for narrow globals and truncates/writes an incomplete
value for wide globals.

## TDD and implementation

`CodeGenGlobalInt8WriteUsesWrtv1` constructs this isolated canonical program:

```angelscript
int8 G;
int8 SetAndGet(int8 X) { G = X; return G; }
```

It requires the published function to contain `asBC_WRTV1` and not contain
`asBC_WRTV4`. The test first failed against the old hardcoded path:

```text
int8 global assignment must use WRTV1 from the sealed global type
```

The production change is deliberately one line in `StoreGlobal`:

```cpp
bc.InstrPTR(asBC_LDG, address);
EmitWriteValue(src, dataType);
```

No new ABI selector was introduced. Global writes now use the same sealed-type width
authority as the other memory destinations.

The Frontend canonical CodeGen helper also now runs
`Sema.LayoutScriptClassFields()` before `Seal()`, matching
`asCBuilder::SealCanonicalAST()`. This makes direct tests use the real semantic
pipeline and is harmless for the global-only fixture.

## Test-run selection lesson

The first invocation used the wrong Automation path and matched no tests; that is not
a red test and provided no behavioral evidence. The correct registered path includes
the class's `CodeGen` directory segment:

```text
Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.
FCanonicalASTCodeGenTests.CodeGenGlobalInt8WriteUsesWrtv1
```

The test initially used `GetFunctionByDecl("int8 SetAndGet(int8)")`, whose spelling
did not match the installed declaration normalization. It was narrowed to its unique
name (`GetFunctionByName("SetAndGet")`) so the assertion measures the bytecode ABI,
not declaration formatting. The subsequent run produced the intended `WRTV1` red
failure before the production fix.

## Verification

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 `
  -Label cta-global-width-green-build -TimeoutMs 1800000 -NoXGE
```

Result: **PASS**.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 `
  -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen.FCanonicalASTCodeGenTests.CodeGenGlobalInt8WriteUsesWrtv1" `
  -Label cta-global-width-green -TimeoutMs 600000
```

Result: **1/1 PASS**.

```text
Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST : 87/87 PASS
Angelscript.TestModule.AngelScriptSDK.Compiler              : 513/513 PASS
```

Final records:

- `Saved/Build/cta-global-width-green-build/20260823_012930_218_15d9a466/`
- `Saved/Tests/cta-global-width-green/20260823_012943_187_688337f1/`
- `Saved/Tests/cta-global-width-frontend/20260823_013025_143_e73fbdae/`
- `Saved/Tests/cta-global-width-compiler/20260823_013107_279_ff13979e/Summary.json`

## Scope truth

This closes the local `StoreGlobal` width bite. It does not make mutable globals a
complete production canonical-language feature, does not close remaining `COPY`
width/lifetime work, and does not complete any of the broad canonical compiler,
snapshot/cache, ABI, or cutover tasks. In particular, do not check Tasks 9.5, 9.6,
10.x, 13.2, 13.3, or 13.6 from this result.
