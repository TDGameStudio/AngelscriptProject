# 词法分析 — 草稿总览

整理日期 2026-09-12。本文件是本草稿里 **Lex** 这一块的入口；细节仍在文末叶子 findings。不写插件代码，也不单独开 Change。

产品 spec：`openspec/specs/angelscript/language/frontend/lexing/spec.md`  
对照实现：`Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/`  
活测试：`AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp`

---

## 1. 它是什么

新架构词法是 **`asCTokenizer`**：对着冻结 UTF-8 快照 **一次 `Lex` 出一个 `asCToken`**。选项冻在 `asSLexOptions`，不读 `asCScriptEngine`。拼写留在 snapshot；名字进会话 `asCIdentifierTable`。

不做：解析、预处理、数字/字符串合法性。`#` 只是 `Hash`；行首 `#` 变成指令是 `asCPreprocessor` 的事。

没有单独的 `lexer/` 目录，文件都在 `frontend/`：

| 文件 | 作用 |
|---|---|
| `as_tokenizer.h` / `as_frontend_tokenizer.cpp` | pull `Lex` |
| `as_token.h` / `as_token_kinds.def` | 115 种 + 拼写/关键字/trivia |
| `as_character_stream.h` | 字节游标 |
| `as_frontend_options.h` | `asSLexOptions` 两颗旋钮 |
| `as_identifier_table.*` | intern；关键字种类来自表 |

旧 `Legacy/.../as_tokenizer.cpp` 是隔离参考，不是这条路径。

```
asSLexOptions
├─ Unicode: AsciiOnly（默认）| AllowUnicode
└─ Trivia:  SkipTrivia（默认）| RetainTrivia | RawDirective（扫描里当 Retain）
```

生产 `asCBuilder` Lexed 阶固定 **AsciiOnly + RetainTrivia**。绑定声明解析用默认 SkipTrivia。

---

## 2. 在编译阶梯里的位置

```
SourceReady     冻结 snapshot
      │
      ▼
Lexed           按文件 pull-all → RawTokens     // Builder 用 RetainTrivia
      │
      ▼
Preprocessed    Process(RawTokens)              // Hash + StartOfLine → 指令
      │
      ▼
Declarations…   Parser 丢掉 trivia / EOF
```

Tokenizer 只向前。整文件 token 数组是 Builder/PP 的成本，不是 `Lex` 合同。

`Lex` 按首字节：空白 / 注释 / ASCII 标识符 / UTF-8 / 数字 / 字符串 / 最长标点，否则 `Invalid` 并前进。数字、字符串只扫描。`>>` 是 `ShiftRight`（已测）。

---

## 3. `as_token_kinds.def` 是什么

X-macro 表，不是给人翻的文档（翻起来也方便）。一行四列：`Name, Spelling, Keyword, Trivia`。

**词法这张表**被 `as_token.h` include 六次，生成：枚举、调试名、TCHAR/ANSI 拼写、`asIsKeyword`、`asIsTrivia`。intern / 标点最长匹配走生成出来的函数，不再 include `.def`。

另有 AST 四张节点表（`as_decl_nodes.def` 等），只喂前向声明和 codec/projection，**不生成** `asEDeclKind`。和词法不是同一张表。

115 行 = 8 个空拼写（Invalid / EOF / 空白 / 注释 / Identifier / 数字 / 字符串）+ 53 关键字 + 54 标点。`import` / `UDELEGATE` 不在表里。

---

## 4. 现在有哪些测试，全不全

活的只有 **`TEST_CLASS Lexer`，16 个方法**。公开名已经是：

`Angelscript.UnitTest.NativeEngine.Lexer.<方法>`

只打 `asCTokenizer`。PP / Sema / Builder 会 new tokenizer，不断言种类。Legacy tokenizer 测试没编。

```
16 个方法（对 spec：够用）
├─ 选项冻结、游标、token 不拥有文本
├─ class / 六个 U* / delegate / event；UDELEGATE 不是关键字
├─ 数字贪心长度；0x1e+2 不吞 +
├─ """ heredoc；/* 未闭合；乱字节前进
├─ intern、Skip/Retain、并行可复现、冷热 intern 日志
└─ 点名的 Kind ≈ 26 / 115
```

| 对什么说「全」 | 结论 |
|---|---|
| 现行 lexing spec 场景 | 够用 |
| 115 种 token 点名 | **不全**（约 26 种被 ASSERT） |
| 行覆盖 % | 没跑，未知 |

`if` / `foreach` / `**` / `::` 等多数没有专断言。corpus 比的是个数或投影字符串，分类一起错仍可能绿。

---

## 5. Clang 怎么测（本机 22.1.8）

| 层 | 数量 | 含义 |
|---|---|---|
| `LexerTest.cpp` | 29 | `CheckLex(源, Kind[])` 场景，多半宏/源文本 |
| HLSL Root Signature | 4 | 小语言；**1** 条扫完整 `.def` |
| `unittests/Lex` 合计 | 143 | 其中约 110 条是 PP/头搜索，不是种类 |
| `clang/test/Lexer` | 142 个顶层文件 / 405 条 RUN | lit 边角和诊断 |

C/C++ 主 lexer **不**扫完整 `TokenKinds.def`。种类全表只出现在小 `.def`（HLSL）。我们 107 个有拼写的 kind 规模接近后者。

---

## 6. 已定、未做

| ID | 决定 | 状态 |
|---|---|---|
| Q6 | NativeEngine 单元含 Lex | 已定 |
| Q7 | 共享头 `LexTestHelper.h` | 已定，未建 |
| Q23 | TestDir 嵌套 `NativeEngine.<Unit>` | 已定，未改插件 |
| Q24 | 公开段用 **`Lexer`**，不用 `Lex` | 已定；套上后今天的 `TEST_CLASS Lexer` 要改名，避免 `Lexer.Lexer` |
| Q27 | 「大部分」= 107 有拼写行走表 + 8 个空拼写留现有测试 + `>>`/`**` 最长匹配对 | 已定，**未实现** |

后续种类矩阵（Q27 A），一个方法里循环 `asGetTokenSpellingAnsi` 非空的 Kind：源放这段拼写，Lex 出来必须是这个 Kind。不要手抄 107 对，也不要再写 107 个 `TEST_METHOD`。现有 16 个合同测试保留。

Held：`SourceDiagnostics` 算不算进 `…Lexer` 前缀。

---

## 7. 叶子 findings

| 文件 | 内容 |
|---|---|
| `lexer.md` | 实现、阶梯、`Lex` 分流、选项、文件表 |
| `lexer-tests.md` | 16 个方法清单；spec vs 115 种对照 |
| `lexer-kind-matrix-plan.md` | Q27 表驱动怎么测 |
| `clang-lexer-tests.md` | Clang 测法 + 条数 |
| `def-files.md` | 六张 `.def`；词法 vs AST 两套展开 |
| `test-prefix.md` | 公开前缀；Q23/Q24 |

下一单元若继续同格式：预处理器（token 数组上的 `#if`）。
