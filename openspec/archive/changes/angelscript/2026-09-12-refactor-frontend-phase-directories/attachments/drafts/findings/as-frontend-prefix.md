# What “drop `as_frontend_` on impl files” means

Inspected 2026-09-12. This is a **file rename**, not a C++ rename.

## Meaning

Today many **headers** already use the short name (`as_parser.h`, `as_sema.h`), but the matching **`.cpp`** still says `as_frontend_*`. That prefix is leftover from “this is the replacement frontend implementation.” After reconstruction cutover, the folder is already `frontend/`; the prefix on the `.cpp` is noise.

Dropping it means:

- `#include "frontend/as_parser.h"` 的**类型名不变**：还是 `asCParser` / `asCSema` / `asCTokenizer`
- 只把实现文件改成和头文件同一词干
- 不改函数、不改行为

```text
今天
as_parser.h
└─[implements] as_frontend_parser.cpp          // 头没有 frontend_，cpp 有
   └─[implements] as_frontend_parser_statements.cpp

改完（仍在 frontend/，或 frontend/Parser/）
as_parser.h
└─[implements] as_parser.cpp                   // 和头文件同一词干
   └─[implements] as_parser_statements.cpp
```

Clang 也是这个习惯：`Parser.h` + `ParseStmt.cpp`，不会再写成 `FrontendParseStmt.cpp`。

## Rename map (17 files)

| Now | After (name only) |
|---|---|
| `as_frontend_parser.cpp` | `as_parser.cpp` |
| `as_frontend_parser_statements.cpp` | `as_parser_statements.cpp` |
| `as_frontend_parser_access.cpp` | `as_parser_access.cpp` |
| `as_frontend_sema.cpp` | `as_sema.cpp` |
| `as_frontend_sema_statements.cpp` | `as_sema_statements.cpp` |
| `as_frontend_sema_access.cpp` | `as_sema_access.cpp` |
| `as_frontend_sema_conversion.cpp` | `as_sema_conversion.cpp` |
| `as_frontend_sema_initializer.cpp` | `as_sema_initializer.cpp` |
| `as_frontend_sema_postfix.cpp` | `as_sema_postfix.cpp` |
| `as_frontend_tokenizer.cpp` | `as_tokenizer.cpp` |
| `as_frontend_source_manager.cpp` | `as_source_manager.cpp` |
| `as_frontend_ast_context.cpp` | `as_ast_context.cpp` |
| `as_frontend_ast_verifier.cpp` | `as_ast_verifier.cpp` |
| `as_frontend_decl.cpp` | `as_decl.cpp` |
| `as_frontend_stmt.cpp` | `as_stmt.cpp` |
| `as_frontend_expr.cpp` | `as_expr.cpp` |
| `as_frontend_options.h` | `as_options.h`（这是唯一带前缀的**头**；里面是 `asSLexOptions`） |

同目录里已经有这种干净拆法：`as_compilation_session.h` + `as_compilation_session_types.cpp`（没有 `frontend_`）。

**不在这张表里：** `angelscript/as_builder_frontend.cpp` 在 SDK 根，是 Builder 实现，不是 `as_frontend_*` 词干。要不要挪、要不要改名，是下一轮的 Builder 问题。

## Not this

- 不是删 `frontend/` 目录
- 不是把 `asCParser` 改成 `Parser`
- 不是再加一层 C++ namespace
