# Section 9 Bytecode CodeGen results

Worktree: `D:\as-cta`  
Canonical pipeline remains **non-default** (`IsCanonicalBytecodeCodeGenReady()` still returns `false`; `SetCompilerPipeline(CANONICAL)` still fail-closes at `asCModule::Build`).

## Shipped backend

`asCBytecodeCodeGen::Generate` is a read-only backend over a sealed AST:

- Rejects unsealed AST (`asAST_VERIFY_UNSEALED_PUBLICATION`).
- Requires a module when function bodies must be published (`asNO_MODULE`).
- Does not mutate AST (dump-equal before/after, including failed Generate).
- Publishes no partial module functions: unsupported bodies fail closed and discard pending functions.
- Owns VM-local state (slots, labels, `asCByteCode`) per function; destroys it after emit.
- Publishes `asCScriptFunction::ScriptFunctionData` (bytecode, `variableSpace`, `stackNeeded`, line numbers, object-variable metadata). `objVariablesOnHeap` is initialized to 0.

Lowering covers:

- Primitive/void functions: literals, params, locals, unary/binary/logical/compare, assign, conversion, `if`/`while`/`do`/`for`/`break`/`continue`/`return`, reverse-formal script-to-script `CALL`/`CallPtr`, `LINE` cues, `SUSPEND` in loops.
- Globals: `CpyGtoV4` / `LDG`+`WRTV4`.
- Value objects: in-place construct (`PSF` + `CALLSYS` after args), member `PSF`/`ADDSi`/`PopRPtr`/`RDR4`/`WRTV4`, destructor cleanup.
- Handles: implicit `asOBJ_REF` handles, `== nullptr` via `CmpPtrNull`.
- Funcdefs/lambdas: `RegisterFuncdef` + `FuncPtr`/`REFCPY`/`CallPtr`.

Parser Sema now attaches the function's own top-level block as the body (nested blocks no longer steal it) and treats `Type Name(args)` local inits as construct, not first-arg assign.

## Tests

| Run | Prefix | Result |
| --- | --- | --- |
| TDD red | `Frontend.CanonicalAST.CodeGen` | 8 tests, **3/8** (expected) |
| After primitive emit | same | **8/8** then **13/13** |
| 9.5 green (`canonical-ast-codegen-95-green4`) | same | **18/18** |
| 9.8 version reject (`canonical-ast-98-codegen`) | same | **19/19** |
| 9.7 isolated differential (`canonical-ast-97-diff`) | `Compiler.CanonicalAST.IsolatedDifferential` | **3/3** |
| 9.8 sidecar version (`canonical-ast-98-cache`) | `Cache.ASTBodySidecar` | **7/7** |
| 9.9 build (`canonical-ast-bytecode`) | `RunBuild.ps1` | exit **0** (up to date) |
| 9.9 SDK (`canonical-ast-bytecode-sdk`) | `Angelscript.TestModule.AngelScriptSDK` | **816/816**, 0 fail, 0 skip |

Isolated differential: primitive/control/call fixtures match legacy execution; bytecode dword counts are reported separately. Script corpus: 37 `.as` files, 27 UE-skipped, 10 native-like, 4 lowered.

`CanonicalSelectionFailsClosedUntilCodeGenExists` remains green: production `Build()` still does not select canonical CodeGen.
