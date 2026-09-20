# Later Lex plan — token-kind matrix (“大部分”)

User 2026-09-12: the 115-kind gap should be scheduled later so they can plan tests for most cases. Not implementing now.

---

## Why a later slice, not 89 new TEST_METHODs

Live `Lexer` already covers the **lexing spec** (options, intern, recovery, U*, trivia). What is missing is a **vocabulary** check against `as_token_kinds.def`.

Empty-spelling rows (8) already have dedicated tests: Invalid, EOF, Whitespace, comments, Identifier, NumericLiteral, StringLiteral. Repeating them in a matrix adds little.

Non-empty spelling rows are 53 keywords + 54 punctuation = **107**. Those are the “大部分”: one authored spelling → one expected `asETokenKind`.

Prefix operators need **pairs**, not isolated rows: `>` `>>` `>>>` `>=` `>>=` `>>>=` and `*` `**` `*=` `**=`. Isolated `>` after `int` is not the same as `>>` at generic close.

```
as_token_kinds.def
├─ 空拼写 ×8          // 已有合同测试，矩阵可不重复
└─ 有拼写 ×107        // 后续矩阵：lex(spelling) → Kind
    └─ 最长匹配对       // >> 对 > ；** 对 * ；不要只测单独一行
```

Recommended later shape (when Lex tests / `LexTestHelper` are applied):

- One (or few) table-driven `TEST_METHOD`s under `Angelscript.UnitTest.NativeEngine.Lexer` (Q23/Q24).
- Rows derived from the `.def` spellings; do not hand-copy 107 kinds into a second list if a small C++ table can walk `asGetTokenSpellingAnsi` + `asIsKeyword`.
- Keep the existing 16 contract methods; the matrix does not replace them.
- Do not treat Sema/VM green as lex coverage.

Q27 settled 2026-09-12 **A**: 107 spelled rows + keep the 8 empty-spelling contract tests + extra maximal-munch pairs. Not implemented.

---

## What “表驱动” means here

Not a second `.def`, not a codegen step. One `TEST_METHOD` + one array (or a loop over `asETokenKind`). Each row is `{ 源文本, 期望 Kind }`。方法里只写一次 `Lex` + `ASSERT`，行数去覆盖种类。

```
不是:
TEST_METHOD(LexPlus)      { … " +" → Plus }
TEST_METHOD(LexPlusPlus)  { … "++" → PlusPlus }
… ×107

而是:
Rows[] = { {"+", Plus}, {"++", PlusPlus}, {"class", KwClass}, … }
TEST_METHOD(SpelledKindsRoundTrip)
  for (Row : Rows)
      Lex(Row.Text) → ASSERT Kind == Row.Kind
```

How to fill the rows later (planned, not written):

1. Walk `asETokenKind` from `0` to `Count-1`.
2. Skip empty `asGetTokenSpellingAnsi` (the 8 structural kinds).
3. Remaining 107 spellings: put that exact text in a snapshot, `Lex` once (or until EOF), first non-trivia token’s Kind must equal that enumerator.
4. Extra **pair** rows for maximal munch: source `">>"` must be one `ShiftRight`, not two `Greater`. Same for `**` `>>>` `>>=` …

`class` is already tested by name today; the matrix would still include it so deleting the `.def` row fails the loop. Existing 16 contract tests stay.

User asked 2026-09-12 what 表驱动 means — this section is the answer.

Clang (see `findings/clang-lexer-tests.md`): C/C++ `LexerTest` uses the same `CheckLex(Source, ExpectedKinds[])` shape per **scenario**, and does **not** walk `TokenKinds.def`. The only “lex every `.def` row” test is HLSL Root Signature (small table). AS’s 107 spelled rows match that small-table case.

---

## Option A in one pass (what the user asked to unpack)

`.def` 115 行分成两类。A 只自动扫第一类。

```
AS_TOKEN(Name, Spelling, Keyword, Trivia)
├─ Spelling == ""     ×8     // Invalid EOF 空白 注释 Identifier 数字 字符串
│                            // A：不进循环。现有 16 个方法继续测这些
└─ Spelling != ""     ×107   // access…UMETA 和 + … #
                             // A：循环 lex(Spelling)，第一种非 trivia 必须是 Name
```

**一步：造源。** 对 `AS_TOKEN(KwClass, "class", true, false)`，snapshot 里只放 UTF-8 `class`（后面可以跟空白）。对 `AS_TOKEN(PlusPlus, "++", false, false)`，源就是 `++`。

**二步：Lex。** 默认 SkipTrivia，拉到第一个 token（或拉到 EOF 取第一个非 trivia）。

**三步：断言。** `Token.Kind == asETokenKind::KwClass`，`Range.Length() == strlen("class")`。拼写从 snapshot 再读出来必须等于 `"class"`。

行从哪来：不要手抄 107 对。循环 `asETokenKind`，`asGetTokenSpellingAnsi(Kind)` 非空就当作一行。那函数就是 `.def` 展开的，删掉 `AS_TOKEN(KwIf, "if", …)` 后 `if` 会变成 Identifier，这一行失败。这就是 HLSL `ValidLexAllTokensTest` include `.def` 的同一意图。

**为什么 8 个空拼写不进这张表。** `Invalid` 的拼写是 `""`，lex `""` 得到的是 EOF，不是 Invalid。`Identifier` 没有固定拼写。`NumericLiteral` 的拼写是无穷集合。这些已经有畸形字节、`Thing`、`.5`、`"""`、`/*` 等合同测试。

**为什么还要「最长匹配对」。** 只测 `>` 和只测 `>>` 是两行独立源。还要证明 **同一段** `">>"` 是一个 `ShiftRight`（长度 2），不是两个 `Greater`。`**` `>>>` `>>=` `>>>=` `**=` 同理。这是多出来的几行，不是 107 里的重复。

**现有 16 个方法。** 不删。A 只补「表上有固定拼写的种类」。U* / class / `>>` 会和矩阵重叠，重叠是故意的：合同测试读起来像故事，矩阵保证 `.def` 增删会被抓住。

还没写进插件。实施挂在后续 Lex / `LexTestHelper` / `…NativeEngine.Lexer` 切片。
