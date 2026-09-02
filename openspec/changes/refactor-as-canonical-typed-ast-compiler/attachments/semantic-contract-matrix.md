# Semantic contract matrix

Maps current HIR/language oracles onto canonical AST, Bytecode, TypedASTJIT, Cache, and the final HIR-removal gate. Logs stay out of `tasks.md`.

| Baseline category | Source tests | Canonical AST requirement | Bytecode consumer | StaticJIT consumer | Cache consumer | Legacy-removal gate |
| --- | --- | --- | --- | --- | --- | --- |
| Source identity / ranges | Frontend Parser source-range + `CanonicalAST.SourceManager` | `asCSourceManager` FileID + `{file,offset}` ranges, authored/processed/generated | debug/coverage/timeout coords from manager | same ranges on eligibility/dump | logical key + origin + offset DTO | no `asCScriptNode` tokenPos as semantic identity |
| Translation unit / namespace / class / enum / funcdef / import | Frontend Parser declarations + Builder declaration tests | matching `asEASTDeclKind` nodes, stable keys | module registration already done by Sema | decl visitors | ModuleInterface / TypeSchema | builder no longer stores parse nodes |
| Function/method/ctor/dtor/param/property | Builder function/property tests | Decl + Param + Property + body Stmt | `asCBytecodeCodeGen` from sealed body | TypedASTJIT root selection | FunctionBody + ASTBodySidecar | `CompileFunction` uses Parser+Sema |
| Primitive/enum/object/template QualType | TypeSystem datatype tests + `CanonicalAST.Type` | interned `asCType` + qualifier mask, Runtime bridge | live `asCDataType` via bridge | same | stable type key, no typeId | HIR `asCDataType` fields gone |
| Literals / refs / unary / binary / assign | Language Expressions + HIR expression tests | `asEASTExprKind` + exact QualType + value category | expr lowering | scalar emission | body sidecar expr records | no `asCExprContext::bc` |
| Calls / rewrite / hidden/default/named args | HIR Call* tests | resolved call node, provenance, reverse formal order | call lowering | native/script call plans | stable declaration keys | no HIR ResolvedCall sidecar |
| Sequence / single-evaluation | HIR mutation tests | Sequence / Opaque-value equivalent nodes | eval order | mutation plans | encoded sequence | no compiler-only eval notes |
| Control / switch / loop phases | Language ControlFlow + HIR control | structured Stmt + verified targets | labels/patches | branch emission | stmt records | no bytecode-local labels in Sema |
| Cleanup / lifetime | HIR cleanup tests | Cleanup / materialize nodes | exception/cleanup tables | cleanup emission | sidecar cleanup | no HIR cleanup plans |
| Globals / imports | Module import + global tests | ImportDecl + global VarDecl | global init bytecode | eligibility | ModuleState | no function-owned HIR globals |
| Typed fallback / Unsupported | TypedASTJIT fallback tests | executable AST never needs `Unsupported` at cutover | VM path | fallback category preserved | N/A | HIR Unsupported enum removed |
| Diagnostics | Compiler diagnostic tests | SourceManager row/col + verifier category | N/A | dump diagnostics | miss-before-mutation | HIR dump terminology gone |
