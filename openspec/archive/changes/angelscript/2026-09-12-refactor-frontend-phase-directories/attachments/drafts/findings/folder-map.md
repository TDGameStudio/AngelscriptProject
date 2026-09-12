# Recommended six-folder file map

Settled 2026-09-12: Q2 A, Q3 B, Q4 B. This is the recommended assignment, not a move yet.

Include shape after the move: `#include "frontend/Lexer/as_tokenizer.h"` (still starts with `frontend/`).

Impl renames from `attachments/drafts/findings/as-frontend-prefix.md` are applied in the “after” names below.

```text
angelscript/
├─ as_builder.h                    // 留在 SDK 根 — Q3 B
├─ as_builder_frontend.cpp         // 留在 SDK 根 — Q3 B；改名见 Q6
├─ as_bytecode_emitter.*           // 不动
└─ frontend/
   ├─ Basic/                       // 源、诊断、标识、语言表面
   ├─ Lexer/                       // token + 预处理器
   ├─ Parser/
   ├─ AST/
   ├─ Sema/
   └─ Compile/                     // session + stages + host 三件套 — Q4 B
```

## Basic/

`as_source_location.h`, `as_source_manager.h`, `as_source_manager.cpp`, `as_source_snapshot.h/.cpp`, `as_source_provenance.h/.cpp`, `as_diagnostics.h/.cpp`, `as_character_stream.h`, `as_identifier_table.h/.cpp`, `as_language_surface.h/.cpp`, `as_function_modifiers.h`, `as_canonical_encoding.h/.cpp`, `as_stable_key.h/.cpp`

## Lexer/

`as_token.h`, `as_token_kinds.def`, `as_tokenizer.h`, `as_tokenizer.cpp`, `as_preprocessor.h/.cpp`, `as_preprocess_result.h/.cpp`, `as_preprocessing_record.h/.cpp`, `as_directive_tree.h/.cpp`, `as_directive_kinds.def`, plus the current `as_frontend_options.h` (only lex knobs: `asSLexOptions`)

## Parser/

`as_parser.h`, `as_parser.cpp`, `as_parser_statements.cpp`, `as_parser_access.cpp`, `as_type_syntax.h`, `as_type_syntax_parser.h/.cpp`

## AST/

`as_ast_fwd.h`, `as_ast_cast.h`, `as_ast_context.h`, `as_ast_context.cpp`, `as_ast_visitor.h`, `as_ast_verifier.h`, `as_ast_verifier.cpp`, `as_ast_codec.h/.cpp`, `as_ast_projection.h/.cpp`, `as_decl.h`, `as_decl.cpp`, `as_decl_nodes.def`, `as_stmt.h`, `as_stmt.cpp`, `as_stmt_nodes.def`, `as_expr.h`, `as_expr.cpp`, `as_attr.h/.cpp`, `as_attr_nodes.def`, `as_type.h/.cpp`, `as_type_nodes.def`, `as_type_loc.h/.cpp`, `as_type_context.h/.cpp`

## Sema/

`as_sema.h`, `as_sema.cpp`, `as_sema_access.cpp`, `as_sema_conversion.cpp`, `as_sema_initializer.cpp`, `as_sema_postfix.cpp`, `as_sema_statements.cpp`, `as_constant_evaluator.h/.cpp`, `as_body_fragment.h/.cpp`, `as_body_lifetime.h/.cpp`, `as_declaration_fragment.h/.cpp`, `as_list_initializer.h`, `as_external_semantics.h`, `as_type_identity.h/.cpp`

## Compile/

`as_compilation_session.h/.cpp` and the six `as_compilation_session_*.cpp`, `as_builder_stages.h`, `as_binding_declaration.h/.cpp`, `as_definition_consumer.h/.cpp`, `as_descriptor_consumer.h/.cpp`

## Deliberate placements

- 预处理器进 `Lexer/`，不单独建 `Preprocess/` — Q2 A。
- `as_type_syntax*` 进 `Parser/`：它是文法，不是 `asCType` 节点。
- `as_type_context` 进 `AST/`：和 `asCASTContext` 一样是类型/节点所有权。
- `as_type_identity` 进 `Sema/`：解析/对齐用的 identity，不是节点存储。
- `as_stable_key` 进 `Basic/`：Engine / TypeInfo 也 include，是基础设施。
- `as_builder.*` 不进 `Compile/` — Q3 B。

## Open names (Round 3)

- `as_frontend_options.h` 的新文件名（内容全是 lex 旋钮）。
- `as_builder_frontend.cpp` 是否改成 `as_builder.cpp`（仍在 SDK 根）。
