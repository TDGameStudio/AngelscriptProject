# Lex unit tests — inventory and how complete they are

Inspected 2026-09-12. Product scanner: `asCTokenizer`. Live suite: one CQTest class.

Public filter today: `Angelscript.UnitTest.NativeEngine.Lexer.*`  
(Q23/Q24 later want TestDir `…NativeEngine.Lexer`; not applied.)

No line-coverage run. “全面” below = spec scenarios + named kind assertions, not llvm-cov %.

---

## 1. What exists

```
活的词法测试
└─ LexerTests.cpp
    └─ TEST_CLASS Lexer                          // 只 asCTokenizer
        ├─ 5 static_assert                       // 选项/token 布局，不读 engine
        └─ 16 TEST_METHOD

旁边会 new tokenizer，但不断言种类
├─ SourceDiagnosticsTests.cpp                    // snapshot 坐标，不是 lex
├─ Preprocessor / Sema / Builder / Definitions   // 把 lex 当夹具
└─ Legacy AngelscriptNativeTokenizer*            // 旧 API，没编
```

16 个方法按目的分组：

| 组 | 方法 | 证明什么 |
|---|---|---|
| 合同 | `FrozenOptionsAreValueOwned` | 选项可拷、不赋值、不来自 engine |
| 合同 | `CharacterStreamUsesValidatedSnapshotRange` | 游标只走合法半开区间 |
| 合同 | `TokenContractIsSourceReferentialAndDeclarative` | 手造 `KwClass`：名字/拼写/keyword/trivia/SOL |
| 分类 | `PullLexerClassifies…` | `class` / `UPROPERTY` / `42` / `"AS"` / `@` / SOL+LeadingSpace |
| 分类 | `OnlySixOuter…` | 六个 `U*` + `delegate` `event`；`UDELEGATE` `import`… 是 Identifier |
| 数字 | `LeadingDotExponentAndRadixNumbers…` | `.5` `1.` `1e+2f` `0x` `0b` `0o` `0d` 以及 `123abc` `0b102` `1e+` 整段长度 |
| 数字 | `HexadecimalEDigitDoesNotAbsorb…` | `0x1e+2` 拆成数字 / `+` / 数字 |
| intern | `RepeatedIdentifiersReuseOneSessionEntry` | 三个 `Thing` 同一条目 |
| 字符串 | `HeredocIsOneLiteral…` | `"""…"""` 跨行、内嵌引号 |
| 标点 | `PostfixAndNestedGeneric…` | `.` `:` `++`，`>>` 是 `ShiftRight` |
| 可复现 | `IndependentSessions…` | 两张表投影相同；默认 SkipTrivia 无 Whitespace |
| Unicode | `UnicodePolicyIsFrozenPerTokenizer` | `πValue` Allow=Identifier / Ascii=Invalid+1002 |
| 恢复 | `MalformedBytesAlwaysAdvanceAndDiagnoseOnce` | `FF 00 $ "x`：非空 range、EOF 可重复、4 条诊断 |
| 恢复 | `UnterminatedBlockCommentConsumesToEnd` | `/*` 到末尾 + Unterminated |
| trivia | `TriviaModesPreserveNonTriviaRanges` | Skip / Retain / RawDirective；`#` 坐标不变；Raw 条数=Retain |
| 并行 | `IndependentParallelSessionsRemainDeterministic` | 16 路 ParallelFor |
| 度量 | `RepresentativeCorpusRecordsColdAndWarmEvidence` | 256× 样例；热跑 intern 不再分配；打日志，无阈值 |

---

## 2. Against the lexing spec — 合同面齐，词汇面不齐

| Spec 场景 | 有没有直接证明 |
|---|---|
| Unicode 政策冻结、不读 engine | 有（`UnicodePolicy…` + static_assert） |
| 同输入同选项 → 相同投影 | 有（双表 + ParallelFor） |
| `Lex` 拉一个、range 指回 snapshot | 有（几乎每个 pull 测试） |
| 重复 ident intern 同一条目 | 有 |
| 六个 U* + delegate/event；UDELEGATE 不是关键字 | 有 |
| 乱字节必前进、诊断一次 | 有（畸形字节 + 未闭合注释） |
| Skip / Retain trivia，非 trivia range 不变 | 有 |
| RawDirective 行为跟 mode 走 | **弱**：只断言条数=Retain，扫描里 Raw=Retain |
| 语料不按 token 堆分配；记录冷/热 | 有日志；**没有**跨机器阈值 |

现行 spec **没有**要求「每个 `asETokenKind` 都有一条用例」。所以按 spec 说：该写的场景基本都有；按「词法表 115 种都测了」说：没有。

---

## 3. Against `as_token_kinds.def` — 大约四分之一被点名

「点名」= `ASSERT` 里出现了那个 `asETokenKind`。fixture 源里写过但没断言的不算（例如 corpus 里的 `if`，错分成 Identifier 计数仍对）。

```
115 kinds
├─ 点名断言 ≈ 26
│   ├─ 结构: Invalid EOF LineComment BlockComment Identifier
│   │         NumericLiteral StringLiteral （Whitespace 只从 Skip 侧「没有」推断）
│   ├─ 关键字: class + 6 个 U* + delegate + event
│   └─ 标点: { @ + . ; : ++ >> #
└─ 未点名 ≈ 89
    ├─ 其余 ~44 个关键字（if foreach Cast mixin fallthrough int …）
    ├─ 其余 ~45 个标点（** >>> <<= && :: == != …）
    └─ 单引号 / ''' heredoc / 空文件 / 非法 tokenizer
```

`int`、`void`、`namespace`、`+=`、`(` `)` `[` `]` `<` 会出现在源字符串里，但没有 `AreEqual(KwInt, …)` 这类断言。`IndependentSessions` 和 corpus **比的是投影字符串或 token 个数**，分类错了两边一起错，仍可能绿。

数字测试证明的是「贪心多长」，不是「`0b102` 非法」。字符串只覆盖了 `"""` 和未闭合 `"`；没有 `'…'`、没有 `'''`。

---

## 4. 诊断 / 选项 / 产品路径

| 面 | 覆盖 |
|---|---|
| `asELexDiagnosticID` 六种 | 都能被畸形/Unicode/注释打出来；**只点名断言了 1002**（UnicodeIdentifierDisallowed） |
| AsciiOnly / AllowUnicode | 有一对 |
| Skip vs Retain | 有 |
| RawDirective | 有调用，无独立行为 |
| Builder 的 AsciiOnly+RetainTrivia | **词法套件没跑**这条产品选项 |
| `FlushDiagnostics` 第二次 | 未测 |
| 行覆盖 % | 未知 |

---

## Conclusions

1. **有单独词法测试**，16 个方法，能用 `…NativeEngine.Lexer` 只跑它们。
2. **对现行 lexing spec：够用。** 冻结选项、intern、恢复、trivia、U* 关键字、可复现、冷热 intern，都有对应用例。
3. **对 115 种 token：不全面。** 没有种类矩阵；大约 26 种被点名，关键字/运算符大多数靠「源里碰巧出现」或完全没出现。
4. **不是行覆盖报告。** 没跑 llvm-cov；「全面」不能说成一个百分比。

## Open

用户要把种类缺口列入**后续计划**（2026-09-12）。边界见 `findings/lexer-kind-matrix-plan.md`；「大部分」等 Q27。
