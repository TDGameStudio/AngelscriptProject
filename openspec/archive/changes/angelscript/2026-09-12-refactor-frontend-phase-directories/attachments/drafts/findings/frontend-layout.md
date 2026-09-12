# Frontend folder vs Clang vs specs

Inspected 2026-09-12. Complements `openspec/specs/angelscript/language/ast/core/knowledges/clang-typed-ast-shape-and-lifetime.md` (AST shape, not directories). Clang tree is `D:\LLVM\llvm-project-22.1.8.src\clang` (tag `llvmorg-22.1.8`).

## One-sentence difference

文档和规格已经按编译阶段分层；源码还是 **107 个文件平铺在一个 `frontend/` 里**，再用 `as_frontend_*` 前缀区分实现文件。Clang 则是 **阶段目录 × include/lib 对拆**。

## How it works today

**Purpose** — `frontend/` 是 reconstructed 语言管线的源码根：lex、preprocess、parse、typed AST、sema、compilation session、以及少量 host consumer。C++ 名字仍在 `BEGIN_AS_NAMESPACE` 里；目录名不是命名空间。

**Lifecycle** — include root 是 `AngelscriptRuntime/angelscript`。活代码写 `#include "frontend/as_*.h"`。Builder 头在 SDK 根 (`as_builder.h`)，阶段枚举在 `frontend/as_builder_stages.h`。Bytecode emit 在 SDK 根，不在 `frontend/`。

**Call chain**

```text
asCBuilder::RunThrough(Stage)                          // SDK 根；阶段机
└─[owns] asCBuilderState                               // 持有 snapshot / session / products
   ├─[calls] asCTokenizer::Lex                         // frontend 平铺
   ├─[calls] asCPreprocessor                           // frontend 平铺
   ├─[calls] asCCompilationSession  ◆                  // CompilerInstance + 阶段机
   │  ├─[owns] asCASTContext                           // AST 竞技场
   │  ├─[owns] asCSema                                 // ActOn*
   │  └─[calls] asCParser::Collect / ParseBody         // 驱动 Sema
   ├─[calls] asCDefinitionConsumer                     // 不是 ASTConsumer；产出 DefinitionSet
   └─[calls] asCByteCodeEmitter                        // SDK 根；不是 frontend/CodeGen
```

## Current source inventory (107 files, one folder)

Classified by Clang-shaped role. Files stay where they are; this is a map, not a move list.

### Basic — source, diagnostics, options, identifiers

`as_source_location.h`, `as_source_manager.h`, `as_frontend_source_manager.cpp`, `as_source_snapshot.h/.cpp`, `as_source_provenance.h/.cpp`, `as_diagnostics.h/.cpp`, `as_character_stream.h`, `as_identifier_table.h/.cpp`, `as_frontend_options.h`, `as_language_surface.h/.cpp`, `as_function_modifiers.h`, `as_canonical_encoding.h/.cpp`, `as_stable_key.h/.cpp`

### Lex

`as_token.h`, `as_token_kinds.def`, `as_tokenizer.h`, `as_frontend_tokenizer.cpp`

### Lex / preprocessor

`as_preprocessor.h/.cpp`, `as_preprocess_result.h/.cpp`, `as_preprocessing_record.h/.cpp`, `as_directive_tree.h/.cpp`, `as_directive_kinds.def`

### Parse

`as_parser.h`, `as_frontend_parser.cpp`, `as_frontend_parser_statements.cpp`, `as_frontend_parser_access.cpp`, `as_type_syntax.h`, `as_type_syntax_parser.h/.cpp`

### AST

`as_ast_fwd.h`, `as_ast_cast.h`, `as_ast_context.h`, `as_frontend_ast_context.cpp`, `as_ast_visitor.h`, `as_ast_verifier.h`, `as_frontend_ast_verifier.cpp`, `as_ast_codec.h/.cpp`, `as_ast_projection.h/.cpp`, `as_decl.h`, `as_frontend_decl.cpp`, `as_decl_nodes.def`, `as_stmt.h`, `as_frontend_stmt.cpp`, `as_stmt_nodes.def`, `as_expr.h`, `as_frontend_expr.cpp`, `as_attr.h/.cpp`, `as_attr_nodes.def`, `as_type.h/.cpp`, `as_type_nodes.def`, `as_type_loc.h/.cpp`, `as_type_context.h/.cpp`

### Sema

`as_sema.h`, `as_frontend_sema.cpp`, `as_frontend_sema_access.cpp`, `as_frontend_sema_conversion.cpp`, `as_frontend_sema_initializer.cpp`, `as_frontend_sema_postfix.cpp`, `as_frontend_sema_statements.cpp`, `as_constant_evaluator.h/.cpp`, `as_body_fragment.h/.cpp`, `as_body_lifetime.h/.cpp`, `as_declaration_fragment.h/.cpp`, `as_list_initializer.h`, `as_external_semantics.h`, `as_type_identity.h/.cpp`

### Compile / session (Clang Frontend-ish)

`as_compilation_session.h/.cpp`, `as_compilation_session_access.cpp`, `as_compilation_session_constants.cpp`, `as_compilation_session_inference.cpp`, `as_compilation_session_lists.cpp`, `as_compilation_session_records.cpp`, `as_compilation_session_types.cpp`, `as_builder_stages.h`

Live **outside** `frontend/`:

- `angelscript/as_builder.h`, `as_builder_frontend.cpp` — Builder / CompilerInstance 入口
- `angelscript/as_bytecode_emitter*` — CodeGen 对等物
- `angelscript/as_compile_output.*`, `as_module_definition_set.*` — 阶段产品

### Host / bindings (no Clang twin)

`as_binding_declaration.h/.cpp`, `as_definition_consumer.h/.cpp`, `as_descriptor_consumer.h/.cpp`

## Naming inconsistency inside the flat folder

17 files still carry an `as_frontend_` prefix. Matching headers usually do not:

| Header | Implementation |
|---|---|
| `as_parser.h` | `as_frontend_parser.cpp` + `_statements` + `_access` |
| `as_sema.h` | `as_frontend_sema.cpp` + five `as_frontend_sema_*.cpp` |
| `as_tokenizer.h` | `as_frontend_tokenizer.cpp` |
| `as_source_manager.h` | `as_frontend_source_manager.cpp` |
| `as_ast_context.h` | `as_frontend_ast_context.cpp` |
| `as_ast_verifier.h` | `as_frontend_ast_verifier.cpp` |
| `as_decl.h` / `as_stmt.h` / `as_expr.h` | `as_frontend_decl.cpp` / `_stmt` / `_expr` |
| `as_frontend_options.h` | header itself has the prefix |

Same folder also uses the cleaner split `as_compilation_session_types.cpp` (no `frontend` in the name). Clang's pattern is `Parser.h` + `ParseStmt.cpp`, `Sema.h` + `SemaExpr.cpp`.

## Clang tree (verified)

Clang does two splits, not one:

```text
clang/
├─ include/clang/          // 公开头；按阶段
│  ├─ Basic/               // 205 files — 诊断、源位置、语言选项、.td/.def
│  ├─ Lex/                 //  34 files — Lexer + Preprocessor 头
│  ├─ Parse/               //   6 files — Parser.h 几乎是全部公开面
│  ├─ AST/                 // 140 files — 节点 + Context + visitors
│  ├─ Sema/                //  67 files — Sema 公开面
│  ├─ CodeGen/             //   9 public headers
│  └─ Frontend/            //  31 files — CompilerInstance / FrontendAction
└─ lib/                    // 同名目录放 .cpp
   ├─ Basic/               // 104
   ├─ Lex/                 //  27 — Lexer.cpp, PPDirectives.cpp, …
   ├─ Parse/               //  19 — ParseStmt.cpp, ParseExpr.cpp, ParseDecl.cpp
   ├─ AST/                 // 154
   ├─ Sema/                //  94 — Sema.cpp, SemaExpr.cpp, …
   ├─ CodeGen/             // 144
   └─ Frontend/            //  43 — CompilerInstance.cpp
```

Include 形状：`#include "clang/Lex/Lexer.h"`，include root 是 `clang/include`。头和实现不共处。

Parse 公开头很少（6），实现按语法种类拆文件。Sema 公开头多、实现也按主题拆。这和我们「头少、`as_frontend_*` 实现按主题拆」是同一想法，只是他们用目录 + `Parse*`/`Sema*` 前缀，我们用一个文件夹 + `as_frontend_` 前缀。

`Frontend/` 在 Clang 里能叫这个名字，是因为顶层已经叫 `clang/`。我们顶层已经叫 `frontend/`，再套一层 `frontend/Frontend/` 会撞名。

## Spec / doc tree (already layered)

```text
openspec/specs/angelscript/language/
├─ surface/                         // 语言表面 / 删除特性 ≈ Basic 语言选项
├─ ast/core/                        // typed AST
├─ types/
│  ├─ definitions/
│  └─ stable-identity/
└─ frontend/
   ├─ source-diagnostics/           // ≈ Basic
   ├─ lexing/                       // ≈ Lex
   ├─ preprocessing/                // ≈ Lex/PP
   ├─ declarations/                 // Parse+Sema 声明阶段（没有独立 parsing spec）
   ├─ bodies/                       // Parse+Sema 函数体阶段
   ├─ builder/                      // 阶段机 / CompilerInstance
   └─ reflection-dependencies/      // Sema 之后的投影
```

每个 capability 常有 `knowledges/clang-*.md`（lexing、preprocessing、source-diagnostics、ast/core）。文档按阶段走；源码没有对应子目录。

没有 `language/frontend/parsing` spec。Parser 被 declarations / bodies 两张阶段合同吃掉。这是规格切法（声明屏障 vs 函数体），不是 Clang 的 Parse/Sema 切法。

## Include contract already settled

`openspec/specs/angelscript/language/ast/core/spec.md`：

- Source directory organization is independent of C++ scope.
- Reconstructed language headers live under `…/angelscript/frontend/`.
- That folder name is not a C++ namespace.
- No extra frontend / V2 C++ namespace.

`openspec/specs/angelscript/language/ast/core/knowledges/first-party-sdk-root.md`：

- Include root = `angelscript/`.
- Live includes are `"as_*.h"` or `"frontend/as_*.h"`.

所以：**可以加 `frontend/Lex/` 这类子目录，不必改 C++ 命名空间。** 子目录仍满足「头在 `frontend/` 下」。改 include 字符串的成本不小：仓库里大量 `#include "frontend/…"`（Runtime、NewVersion tests、Legacy tests）。

## Three pictures

当前源码（平铺）：

```text
angelscript/
├─ frontend/                       // 107 files, 一个袋子
│  ├─ as_tokenizer.h
│  ├─ as_frontend_tokenizer.cpp    // 头没有 frontend_，实现有
│  ├─ as_parser.h
│  ├─ as_frontend_parser.cpp
│  ├─ as_sema.h
│  ├─ as_frontend_sema.cpp
│  ├─ as_decl.h / as_stmt.h / as_expr.h
│  ├─ as_compilation_session.*
│  └─ as_definition_consumer.*     // host 边界也在这里
├─ as_builder.h                    // CompilerInstance 入口在外面
├─ as_builder_frontend.cpp
└─ as_bytecode_emitter.*           // CodeGen 在外面
```

规格（已分层）：

```text
language/frontend/lexing
language/frontend/preprocessing
language/frontend/source-diagnostics
language/frontend/declarations
language/frontend/bodies
language/frontend/builder
language/ast/core
language/types/…
```

Clang（阶段目录 + include/lib）：

```text
include/clang/{Basic,Lex,Parse,AST,Sema,Frontend,CodeGen}
lib/{Basic,Lex,Parse,AST,Sema,Frontend,CodeGen}
```

## What we should not copy from Clang

1. **include/ vs lib/ 对拆** — UE 模块习惯头和 cpp 同目录；107 个文件再翻一倍路径，收益小。
2. **`frontend/Frontend/`** — 顶层已经叫 frontend。
3. **把 bytecode emit 搬进 frontend/CodeGen** — 已有意放在 SDK 根；AST→bytecode 研究稿也按这个边界写。
4. **Clang 式 `clang::` 嵌套命名空间** — 规格禁止再加一层 frontend/V2 命名空间。
5. **TableGen / 205 个 Basic 头** — 我们用少量 `.def` X-macro，不需要 Clang Basic 的体量。

## What is worth copying (if we normalize)

1. **阶段子目录**，头和 cpp 仍共处：`Basic/`, `Lex/`, `Parse/`, `AST/`, `Sema/`, `Compile/`（或 `Session/`，避免 Frontend 撞名）。
2. **实现文件丢掉 `as_frontend_`**，改成 Clang 那种 `as_parser_statements.cpp` / `as_sema_statements.cpp`，和已有的 `as_compilation_session_types.cpp` 对齐。
3. **include 继续从 `frontend/` 起**，例如 `"frontend/Lex/as_tokenizer.h"`，不新增 include root，避免和 `"as_scriptengine.h"` 抢短名。

## Active-work collision

- `angelscript/test-lexer-isolated-coverage` 正在动 lex 测试与 frontend 词法面。
- `angelscript/refactor-bindings-two-stage-pipeline` 点名 `as_binding_declaration.*`。

目录搬家是独立 Change，不应塞进这两个进行中的工作。

## Conclusions / Open

**结论**

- 规格树已经比源码树更接近 Clang。
- 源码的不规范主要是：一个平铺目录 + `as_frontend_` 实现前缀 + Builder 入口在 `frontend/` 外。
- 规格已允许「目录可拆、C++ 作用域不可拆」。
- 完整抄 Clang 的 include/lib 和 `Frontend/` 子名不合适。

**Open（用户决策，见 Round 1）**

1. 规范化先动哪一层：阶段子目录、只改文件名、两者一起、还是只对齐文档？
2. （取决于 1）子目录叫 Clang 名还是跟 spec id（`lexing` / `source-diagnostics`）？
3. （取决于 1）`as_builder.*` 是否迁入 `frontend/Compile/`？
4. 要不要补 `language/frontend/parsing` spec，还是继续用 declarations/bodies 切 Parser？
