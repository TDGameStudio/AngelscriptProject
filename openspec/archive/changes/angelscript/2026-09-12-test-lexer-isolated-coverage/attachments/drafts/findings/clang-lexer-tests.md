# How Clang tests lexing (LLVM 22.1.8)

Inspected `D:/LLVM/llvm-project-22.1.8.src`. Not a copy-target for C macros or FileCheck; the useful part is **how they split contract tests vs vocabulary**.

---

## Three layers

```
clang/unittests/Lex/LexerTest.cpp     // gtest：场景 + CheckLex(源, 期望 kinds[])
clang/unittests/Lex/LexHLSL*.cpp      // 小语言：一份源里写齐 .def 全部 token
clang/test/Lexer/*.c(pp)  ~159 文件   // lit + FileCheck / -verify：边角、诊断、标准差异
```

`clang/unittests/Lex/` 一共 12 个 cpp（再加 CMake / HeaderMap 头）。2026-09-12 对 LLVM 22.1.8 的计数：

| 层 | 条数 | 是什么 |
|---|---|---|
| `LexerTest.cpp` | **29**（28 `TEST_F` + 1 `TEST`） | C/C++ `CheckLex` 场景，多半是宏/源文本/raw lex |
| `LexHLSLRootSignatureTest.cpp` | **4** | 小语言；其中 1 个扫完整 `.def` |
| `unittests/Lex` 其余 | **110** | PP、HeaderSearch、模块、依赖扫描，**不是** token 种类 |
| `unittests/Lex` 合计 | **143** | 整个 Lex 单元测试目录 |
| `clang/test/Lexer` 顶层用例文件 | **142**（不含 Inputs、`.h`、`.txt`） | lit；目录一共 161 个文件 |
| 这些 lit 里的 `// RUN:` | **405** | 同一文件常跑多次（标准/三字符等） |
| lit 里 expected-error/warning | 648 处 | 诊断断言，不是 Kind 枚举 |
| lit 里 `CHECK` | 546 处 | FileCheck |

「Clang 词法测试有多少」不要说成 143 或 400+ 一种数：和 AS `Lexer` 16 个方法对得上的，是 **29 + 4**；边角海是 **142 个 lit 文件 / 405 条 RUN**。

---

## 1. C/C++：`CheckLex`，不扫完整 `TokenKinds.def`

```cpp
// 简化自 LexerTest.cpp
std::vector<Token> CheckLex(StringRef Source, ArrayRef<tok::TokenKind> Expected)
{
    auto toks = Lex(Source);                    // 实际走 Preprocessor::LexTokensUntilEOF
    EXPECT_EQ(Expected.size(), toks.size());
    for (i) EXPECT_EQ(Expected[i], toks[i].getKind());
}

CheckLex("int i = ONE;", {tok::kw_int, tok::identifier, tok::equal,
                          tok::numeric_constant, tok::semi});
```

这就是表驱动，但表是 **「这一段源 → 这一串 Kind」**，不是「枚举里每一个 Kind 一行」。

`TokenKinds.def` 里光 `PUNCTUATOR`/`KEYWORD` 就两百多行，再加 C++11/C23/ObjC/注解。Clang **没有**在 unittest 里循环 `tok::NUM_TOKENS` 去 lex 每个拼写。Format 测试会用 `getPunctuatorSpelling` 拼运算符，那是格式化，不是 lex 完备性。

`LexerTest` 测的是合同和坑：宏展开后的源文本、raw vs normal、行注释、转义换行、preamble 边界。关键字只在场景里顺带出现（`int`）。

---

## 2. 小语言才「.def 全表 lex 一遍」

HLSL Root Signature 的 token 集很小。`ValidLexAllTokensTest`：

1. 手写一份源，把 `.def` 里会出现的拼写都写进去。
2. 期望数组 **直接 include 同一份 `.def`**：

```cpp
SmallVector<TokenKind> Expected = {
#define TOK(NAME, SPELLING) TokenKind::NAME,
#include "clang/Lex/HLSLRootSignatureTokenKinds.def"
};
checkTokens(Lexer, Tokens, Expected);
```

这才是「种类表本身当测试表」。C/C++ 主 lexer 没有等效测试。

---

## 3. lit：边角和诊断，不是种类枚举

`clang/test/Lexer/` ~159 个文件。典型 `constants.c`：非法八进制、过大整型、多字符常量 —— `// expected-error` / FileCheck，**不断言 `tok::numeric_constant` 这个枚举值**。测的是诊断和语言规则，种类对错由编译器后级一起绿。

---

## 对照 AngelScript

| | Clang C/C++ lex | Clang HLSL RS | 我们现在 | 后续「大部分」可抄谁 |
|---|---|---|---|---|
| 辅助函数 | `CheckLex(源, kinds[])` | `checkTokens` | `CaptureTokenProjection` | 应有 `CheckLex` |
| 走完整 `.def` | 否（表太大） | **是** | 否 | AS 只有 **107** 个有拼写，学 HLSL 划算 |
| 合同/坑 | `LexerTest` ~28 | 另有 casefold 等 | 已有 16 个 | 保留，不要改成种类表 |
| 边角文件海 | ~159 lit | 少 | 没有 | 不必抄 159；缺了再补单场景 |

Clang 主 lexer **并不**追求 115/400 种点名。他们用场景序列 + 大量 lit。种类全表只出现在 **小 `.def`** 上。

我们的 `as_token_kinds.def` 规模接近 HLSL RS，不接近 C `TokenKinds.def`。所以后续计划学 HLSL 的「include `.def` / 扫有拼写的 Kind」是 Clang 里真正对得上的做法；现有 16 个方法已经是 `LexerTest` 那一层。

---

## Conclusions

1. Clang 词法单测的核心是 **`CheckLex(源文本, 期望 Kind 序列)`**，不是 107 个 `TEST_METHOD`。
2. **完整种类表**只在小语言（HLSL RS）里做；C/C++ 不做。
3. 边角靠 `clang/test/Lexer` lit，不靠 gtest 枚举。
4. AS 后续「大部分」按 HLSL 方式覆盖 107 个有拼写行，比抄 C++ lit 更贴 Clang 实际分工。
