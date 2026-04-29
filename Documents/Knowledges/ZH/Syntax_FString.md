# `f-string` 格式化字符串实现原理

> 本文记录 AngelScript 插件中 **f-string** 字面量的完整实现：从源码字符 `f"Hello {name}"` 到运行时 `FString` 拼接结果的全链路。
>
> 与 `Syntax_DefaultStatement.md` / `Syntax_UPROPERTY.md` 等文档同属"语法机制"系列，但 f-string 的实现完全发生在**预处理器层面**——AS 编译器看到的是普通的 `FString` 链式调用，对 f-string 字面量本身**完全无感知**。

---

## 概览

f-string 是当前项目对 AS 提供的**字符串插值语法糖**，灵感来自 Python f-string + Rust `format!` + .NET `String.Format`。一个典型用法：

```text
.as 源码:
    Print(f"Player {PlayerName} has {Health:0.2f} HP and {Coins:,} coins.");

预处理器展开为:
    Print((FString().Append("Player ").Append(PlayerName)
                    .Append(" has ").Append(FString::ApplyFormat((Health), "0.2f"))
                    .Append(" HP and ").Append(FString::ApplyFormat((Coins), ","))
                    .Append(" coins.")));

AS 编译器看到的就是普通的 FString 链式 Append, 完全不知道 f-string 的存在。
```

### 4 阶段管线

```text
预处理器层 (Preprocessor)              AS 编译器层 (ThirdParty/angelscript)
============================           ====================================
ParseIntoChunks 字符级状态机:           完全无视 f-string 字面量, 只看到:
  case 'f' + 紧跟 '"' + 标识符起点         (FString().Append(...).Append(...))
  -> 标记 FormatStringStart                普通的 AS 表达式 + 链式方法调用
  | 后续 '"' 闭合时触发:
  v
GenerateFormatString(FFile, FormatStr)
  - 扫描 { } 配对, 拆分为字面量 / 表达式
  - 处理转义 {{ -> '{', }} -> '}'
  - 生成 FString().Append("...").Append((expr)).Append(...) 链式代码
  | 每个 {expr} 单独处理:
  v
ParseFormatExpression(FFile, FormatExpr)
  - 检测格式说明符 :spec (从右向左扫描)
  - 检测自描述模式 expr= (打印表达式名+值)
  - 三种产物形式:
    + "name = " + (expr)              (自描述, 无格式说明符)
    + FString::ApplyFormat((expr), "spec")     (格式说明符, 无自描述)
    + "name = " + FString::ApplyFormat((expr), "spec")  (两者皆有)
  | 替换源码:
  v
源码就地改写
  PendingReplaces.Add({StartPos, EndPos+1, GeneratedCode})
        |
        v
运行时层 (Bind_FString.cpp)
====================================
FString::ApplyFormat(?& Value, const FString& Specifier) -> FString
  - 12 个 ApplyFormat 重载 (覆盖 int8/16/32/64 + uint*/float32/64/bool/FString/任意类型)
  - FFormatSpecifier 解析格式说明符 (5 阶段状态机:
    OnStart -> OnSign -> OnAlternateForm -> OnMinimumWidth -> OnPrecision -> OnType)
  - 返回格式化后的 FString
```

### 核心特性速览

| 特性 | 语法 | 实现策略 |
|------|------|---------|
| **基础插值** | `f"Hello {name}"` | `.Append("Hello ").Append(name)` |
| **格式说明符** | `f"{value:0.2f}"` | `.Append(FString::ApplyFormat((value), "0.2f"))` |
| **自描述（debug 友好）** | `f"{value=}"` | `.Append("value = ").Append((value))` |
| **自描述 + 格式说明符** | `f"{value=:0.2f}"` | `.Append("value = ").Append(FString::ApplyFormat((value), "0.2f"))` |
| **转义大括号** | `f"{{` / `f"}}` | `.AppendChar('{')` / `.AppendChar('}')` |
| **任意 AS 表达式** | `f"{a + b * 2}"` | `.Append((a + b * 2))` —— 支持完整 AS 表达式 |
| **类型扩展** | 任意有 `opAdd(FString)` 或 `ApplyFormat` 重载的类型 | `Append` 支持的全部类型 + `ApplyFormat` 12 个重载 |

---

## 一、词法识别：`case 'f'` 状态机分支

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:3813` `ParseIntoChunks`。

### 1.1 起点识别（L3813-L3823）

```cpp
case 'f':
    // F-Strings
    if ((RawSize - ChunkEnd) >= 3
        && !bInComment
        && !bInString
        && IsStartOfIdentifier()
        && File.RawCode[ChunkEnd+1] == '"')
    {
        FormatStringStart = ChunkEnd;     // 记录起点 (指向 'f' 字符位置)
    }
break;
```

5 个识别条件**同时满足**才标记 `FormatStringStart`：

| 条件 | 含义 |
|------|------|
| `(RawSize - ChunkEnd) >= 3` | 至少还剩 3 个字符（`f"x"` 最短形式） |
| `!bInComment` | 不在 `//` 或 `/* */` 注释内 |
| `!bInString` | 不在已开启的字符串字面量内 |
| `IsStartOfIdentifier()` | 当前 `f` 是新标识符的起点（不是其他词的中段，如 `iframe`） |
| `RawCode[ChunkEnd+1] == '"'` | `f` 紧跟一个 `"` 字符 |

### 1.2 终点触发（L3941-L3957）

`'"'` 字符同时承担字符串字面量的开 / 关角色。在 `case '"'` 分支中：

```cpp
if (!bInEscapeSequence)
{
    bInString = !bInString;             // 切换字符串状态

    if (!bInString && NameLiteralStart != -1 && NameLiteralStart >= ChunkStart)
    {
        // n"..." Name 字面量结束 -> 走 GenerateStaticName
    }
    else if (!bInString && FormatStringStart != -1 && FormatStringStart >= ChunkStart)
    {
        // ★ f"..." 字面量结束 -> 走 GenerateFormatString
        FString FormatStr = File.RawCode.Mid(
            FormatStringStart + 2,                      // 跳过 'f' + '"' 起始两字符
            ChunkEnd - FormatStringStart - 2);          // 不含尾部 '"'
        FString GeneratedCode = GenerateFormatString(File, FormatStr);
        PendingReplaces.Add({
            FormatStringStart - ChunkStart,             // chunk 内的起始偏移
            ChunkEnd - ChunkStart + 1,                  // 包括尾 '"' 的结束偏移
            GeneratedCode                               // 生成的替换代码
        });
        FormatStringStart = -1;
    }
}
```

### 1.3 与其他字面量的协作

预处理器同时处理三类带前缀的字符串字面量，**共享相同的 `case '"'` 终点逻辑**：

| 前缀 | 全名 | 处理函数 | 用途 |
|------|------|---------|------|
| `f"..."` | f-string | `GenerateFormatString` | 字符串插值 |
| `n"..."` | name literal | `GenerateStaticName` | 编译期 FName 缓存 |
| `"..."` | 普通字符串 | （无） | 直接传给 AS 编译器 |

`FormatStringStart` 与 `NameLiteralStart` 是平行的状态变量，互不干扰：`f"..."` 触发前者，`n"..."` 触发后者，普通 `"..."` 两者都不触发。

### 1.4 行尾重置防御

```cpp
case '\n':
    // ...
    NameLiteralStart = -1;
    FormatStringStart = -1;             // 行尾强制重置
    ++LineNumber;
break;
```

如果 f-string 跨行未闭合（`f"...` 后直接换行），状态机会在行尾**强制丢弃**起点标记，避免后续误识别。这意味着**当前项目的 f-string 不支持跨行**——必须在同一行内完成。

### 1.5 与 ChunkStart 的边界保护

```cpp
else if (!bInString && FormatStringStart != -1 && FormatStringStart >= ChunkStart)
                                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

`FormatStringStart >= ChunkStart` 防御：如果 f-string 起点在上一个 chunk 中（即跨 chunk 字面量），不会触发本 chunk 的 `GenerateFormatString` 调用——同样间接禁止了跨 chunk 的 f-string。

---

## 二、`GenerateFormatString` —— 主流程展开

**源码所在**：`AngelscriptPreprocessor.cpp:1970` `FAngelscriptPreprocessor::GenerateFormatString`。

### 2.1 基础结构

```cpp
FString FAngelscriptPreprocessor::GenerateFormatString(FFile& File, const FString& FormatStr)
{
    FString Result;
    Result.Reserve(FormatStr.Len() + 128);
    Result.Append(TEXT("(FString()"));         // [起头] 用空 FString() 开始链式

    int32 StartPosition = 0;                   // 当前文本片段起点
    int32 Parts        = 0;                    // 已生成的 .Append 数量（仅作统计）
    int32 Length       = FormatStr.Len();
    bool  bInExpression = false;               // 当前是否在 { } 内

    for (int32 CurPosition = 0; CurPosition < Length; ++CurPosition)
    {
        int16 Char = FormatStr[CurPosition];
        switch (Char)
        {
        case '{':
            /* 详见 §2.2 */
        break;
        case '}':
            /* 详见 §2.3 */
        break;
        }
    }

    // [尾部] 收尾未消费的尾部文本
    if (!bInExpression && Length > StartPosition)
    {
        Result.Append(TEXT(".Append(\""));
        Result.Append(FormatStr.Mid(StartPosition, Length - StartPosition));
        Result.Append(TEXT("\")"));
    }

    Result.AppendChar(')');                    // [闭合] 整个 FString() 链式表达式
    return Result;
}
```

整个生成结果被包在一对**外层括号** `(...)` 中——这是为了让 f-string 表达式可以**作为整体被传给函数参数 / 赋值给变量 / 参与运算符**。

### 2.2 `'{'` 分支：开启表达式 / 转义

```cpp
case '{':
{
    if (!bInExpression)                                // 仅在表达式外才有意义
    {
        // [a] 先把累积的字面量片段冲刷出去
        if (CurPosition > StartPosition)
        {
            Result.Append(TEXT(".Append(\""));
            Result.Append(FormatStr.Mid(StartPosition, CurPosition - StartPosition));
            Result.Append(TEXT("\")"));
            Parts += 1;
        }

        // [b] 检测 {{ 转义
        if (CurPosition + 1 < Length && FormatStr[CurPosition + 1] == '{')
        {
            Result.Append(TEXT(".AppendChar('{')"));   // 转义为字面 '{'
            CurPosition += 1;                          // 吃掉第二个 '{'
            StartPosition = CurPosition + 1;
        }
        else
        {
            // [c] 进入表达式状态
            StartPosition = CurPosition + 1;            // 表达式起点 (跳过 '{')
            bInExpression = true;
        }
    }
}
break;
```

### 2.3 `'}'` 分支：闭合表达式 / 转义

```cpp
case '}':
    if (bInExpression)
    {
        // [a] 在表达式内 -> 闭合
        if (CurPosition > StartPosition)
        {
            Result.Append(TEXT(".Append("));
            FString Expression = FormatStr.Mid(StartPosition, CurPosition - StartPosition);
            Result.Append(ParseFormatExpression(File, Expression));    // ★ 解析 expr [+ spec]
            Result.AppendChar(')');
            Parts += 1;
        }
        StartPosition = CurPosition + 1;
        bInExpression = false;
    }
    else
    {
        // [b] 不在表达式内, 检测 }} 转义
        if (CurPosition + 1 < Length && FormatStr[CurPosition + 1] == '}')
        {
            // 先冲刷字面量
            if (CurPosition > StartPosition)
            {
                Result.Append(TEXT(".Append(\""));
                Result.Append(FormatStr.Mid(StartPosition, CurPosition - StartPosition));
                Result.Append(TEXT("\")"));
                Parts += 1;
            }

            Result.Append(TEXT(".AppendChar('}')"));   // 转义为字面 '}'
            CurPosition += 1;
            StartPosition = CurPosition + 1;
        }
        // 注意: 单独 '}' 既不闭合也不转义, 直接被吞掉 (累积到下一段字面量)
    }
break;
```

### 2.4 容错策略

| 场景 | 处理 |
|------|------|
| 单独 `'{'` 字面量（不在表达式内）| 进入表达式状态——后续找不到 `'}'` 时整段被吞，**生成代码可能不平衡**（编译期 AS 报错） |
| 单独 `'}'` 字面量（不在表达式内）| 直接被吞，下一段字面量从下一个字符开始 |
| `'{'` 在表达式内（即 `{{`）| 当前实现**不视为转义**——内层 `'{'` 在 case 中被忽略，会在表达式中保留为字符（多半使表达式编译失败） |
| 表达式内未闭合到结尾 | `bInExpression=true` 但循环结束 → 末尾代码不刷入，整体 `FString()` 闭合后多一个孤立 `(`（编译期 AS 报错） |
| 空表达式 `{}` | `CurPosition > StartPosition` 不成立 → 静默跳过，不生成 `.Append()` |
| 空 f-string `f""` | 循环不进入，`Length > StartPosition` 不成立 → 直接生成 `(FString())` |

### 2.5 生成结果示例

| f-string 源码 | 生成代码 |
|--------------|---------|
| `f""` | `(FString())` |
| `f"hi"` | `(FString().Append("hi"))` |
| `f"{x}"` | `(FString().Append(x))` |
| `f"a={x}"` | `(FString().Append("a=").Append(x))` |
| `f"{x}{y}"` | `(FString().Append(x).Append(y))` |
| `f"{{x}}"` | `(FString().AppendChar('{').Append("x").AppendChar('}'))` |
| `f"{x:0.2f}"` | `(FString().Append(FString::ApplyFormat((x), "0.2f")))` |
| `f"{x=}"` | `(FString().Append("x = "+(x)))` |
| `f"{x=:0.2f}"` | `(FString().Append("x = "+FString::ApplyFormat((x), "0.2f")))` |

---

## 三、`ParseFormatExpression` —— 单个 `{...}` 表达式解析

**源码所在**：`AngelscriptPreprocessor.cpp:2067` `FAngelscriptPreprocessor::ParseFormatExpression`。

### 3.1 入参与目标

```cpp
FString ParseFormatExpression(FFile& File, const FString& FormatExpr);
// FormatExpr 是 {...} 大括号内部的原始字符串 (不含 { } 本身)
// 例如: "x"  /  "x=:0.2f"  /  "Health:0.2f"  /  "a + b * 2"
```

目标：识别 3 种形式并产出对应的 AS 表达式片段：

| 输入形式 | 输出 |
|---------|------|
| `expr` | `expr` （直接返回，无装饰） |
| `expr=` | `"expr = "+(expr)` |
| `expr:spec` | `FString::ApplyFormat((expr), "spec")` |
| `expr=:spec` | `"expr = "+FString::ApplyFormat((expr), "spec")` |

### 3.2 核心算法：从右向左扫描

```cpp
FString ParseFormatExpression(FFile& File, const FString& FormatExpr)
{
    int32 EqualsPos = -1;                    // 自描述 '=' 位置
    bool  bFoundFormat = false;              // 是否已遇到非格式说明符字符

    int32 Pos = FormatExpr.Len() - 1;
    for (; Pos >= 0; --Pos)                  // ★ 从右向左
    {
        int16 Char = FormatExpr[Pos];
        if (Char == ' ' || Char == '\t')
            continue;                        // 跳过末尾空白

        // [1] 检测自描述 '='
        if (Char == '=' && !bFoundFormat)
        {
            EqualsPos = Pos;
            continue;
        }

        // [2] 标记: 一旦遇到任何非空白非 '=' 字符, 后续 '=' 不再视为自描述
        bFoundFormat = true;

        // [3] 检测格式说明符分隔 ':'
        if (Char == ':')
        {
            FString Specifier = FormatExpr.Mid(Pos+1);

            if (Pos > 0 && FormatExpr[Pos - 1] == '=')
            {
                // [3a] expr=:spec 形式
                FString Expr = FormatExpr.Mid(0, Pos - 1);
                Expr.TrimStartAndEndInline();
                return FString::Printf(
                    TEXT("\"%s = \"+FString::ApplyFormat((%s), \"%s\")"),
                    *Expr, *Expr, *Specifier);
            }
            else
            {
                // [3b] expr:spec 形式
                FString Expr = FormatExpr.Mid(0, Pos);
                return FString::Printf(
                    TEXT("FString::ApplyFormat((%s), \"%s\")"),
                    *Expr, *Specifier);
            }
        }

        // [4] 检测格式说明符的"合法字符" (仅在已进入说明符段时才放行)
        bool bValidFormatSpec = false;
        switch (Char)
        {
        case '0': case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9':
        case 'd': case 'x': case 'X': case 'b': case 'c':
        case 'o': case 'n': case 'e': case 'E':
        case 'f': case 'F': case 'g': case 'G':
        case '%': case ',': case '.': case '-': case '+':
        case '(': case '#':
            bValidFormatSpec = true;
        break;
        case '<': case '>': case '^': case '=':
            // 对齐符: 前面可能跟一个 fill 字符
            if (Pos > 0 && FormatExpr[Pos-1] != ':')
                --Pos;
            bValidFormatSpec = true;
        break;
        }

        if (!bValidFormatSpec)
            break;          // 遇到非合法说明符字符 -> 终止扫描
    }

    // [5] 没有找到 ':' 但找到了 '=' -> 自描述, 无格式说明符
    if (EqualsPos != -1)
    {
        FString Expr = FormatExpr.Mid(0, EqualsPos);
        Expr.TrimStartAndEndInline();
        return FString::Printf(TEXT("\"%s = \"+(%s)"), *Expr, *Expr);
    }
    else
    {
        // [6] 既无 ':' 也无 '=' -> 直接返回原表达式
        return FormatExpr;
    }
}
```

### 3.3 算法关键洞察

#### 为什么从右向左扫描？

格式说明符（spec）总是在 `:` 之后，位于表达式末尾。从右扫描可以：

- 优先识别说明符（避免与表达式中的 `:` 冲突，如 `Math::Pi`）
- 一旦遇到**非合法说明符字符**就立即停止，剩余左半部分整体视为 expr

#### 三阶段状态

```text
状态机:
  从右开始扫描
    -> 跳过空白
    -> 检测 '=' (仅当还没遇到非空白非'='字符时)
    -> 进入"扫描合法说明符字符"阶段 (bFoundFormat=true)
       - 数字/类型字符/对齐符/精度点等 -> 继续向左
       - ':' -> 找到说明符分隔, 立即生成代码并返回
       - 其他 -> 终止扫描 (没有找到 ':')
  扫描结束:
    EqualsPos != -1 -> 自描述
    否则           -> 原表达式
```

#### 为什么 `Math::Pi` 不会被误识别为带说明符？

```text
扫描 "Math::Pi":
  Pos=7: 'i' -> 不在合法说明符字符集 -> 终止扫描
  -> 没找到 ':' -> 原表达式 "Math::Pi"
```

`'i'` 不是合法说明符字符，扫描到此立即终止，整段 `Math::Pi` 直接作为表达式返回——避免了误把 `Math:` 当成说明符分隔。

#### 对齐符的特殊处理

```cpp
case '<': case '>': case '^': case '=':
    if (Pos > 0 && FormatExpr[Pos-1] != ':')
        --Pos;                    // 跳过 fill 字符
    bValidFormatSpec = true;
break;
```

格式 `*<10`（左对齐，宽度 10，填充 `*`）中，`*` 是 fill 字符。扫描到 `<` 时，主动 `--Pos` 把 `*` 也吞掉，避免 `*` 被当成"非合法说明符字符"导致扫描提前终止。

### 3.4 自描述模式的 `=` 优先级

```cpp
if (Char == '=' && !bFoundFormat)
{
    EqualsPos = Pos;
    continue;
}
```

`!bFoundFormat` 是关键：自描述的 `=` **必须出现在所有合法说明符字符的最右侧**——这是为了支持 `{x=:0.2f}` 这种"先 `=`、后 `:0.2f`"的形式。

但 `=` 也是格式说明符的"对齐符"之一（`AfterSign` 对齐）。两者怎么区分？

```text
"x="       -> 末尾 '=', 没有 ':' -> 自描述
"x=:0.2f"  -> 扫描到 ':' 时检测到 Pos-1 是 '=' -> 自描述+spec
"x=10"     -> '0' 是合法说明符字符, 在 '=' 之前已进入 bFoundFormat
              -> 后续 '=' 不视为自描述
              -> 但因为没找到 ':', 最终返回原表达式 "x=10"
"x=:>10"   -> 扫描 '0' '1' (合法), '>' (对齐符, 跳 fill), ':' (找到!)
              -> Pos-1 是 '=' -> 自描述+spec, Specifier=">10"
```

设计精妙处：`=` 既能作自描述标记（在末尾时）又能作对齐符（在 `:` 之后），状态机用扫描方向 + `bFoundFormat` 标志精确区分两者语义。

---

## 四、运行时绑定：`FString::ApplyFormat`

**源码所在**：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp:1300-1313`。

### 4.1 12 个 ApplyFormat 重载

```cpp
// 整数类型 (8 个)
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(int32 Value, const FString& Specifier)",
    &ApplyFormatInteger<int32, false, uint32>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(uint32 Value, const FString& Specifier)",
    &ApplyFormatInteger<uint32, true, uint32>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(int64 Value, const FString& Specifier)",
    &ApplyFormatInteger<int64, false, uint64>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(uint64 Value, const FString& Specifier)",
    &ApplyFormatInteger<uint64, true, uint64>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(int16 Value, const FString& Specifier)",
    &ApplyFormatInteger<int16, false, uint16>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(uint16 Value, const FString& Specifier)",
    &ApplyFormatInteger<uint16, true, uint16>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(int8 Value, const FString& Specifier)",
    &ApplyFormatInteger<int8, false, uint8>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(uint8 Value, const FString& Specifier)",
    &ApplyFormatInteger<uint8, true, uint8>);

// 浮点 (2 个)
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(float32 Value, const FString& Specifier)",
    &ApplyFormatFloat<float>);
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(float64 Value, const FString& Specifier)",
    &ApplyFormatFloat<double>);

// 布尔 (1 个)
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(bool Value, const FString& Specifier)",
    &ApplyFormatBool);

// FString (1 个)
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(const FString& Value, const FString& Specifier)",
    &ApplyFormatString);

// (*) 任意类型兜底 (使用 ?& 通配引用)
FAngelscriptBinds::BindGlobalFunction("FString ApplyFormat(const ?& Value, const FString& Specifier)",
    &ApplyFormat);
```

### 4.2 重载选择规则

AS 编译器在 `f"{value:0.2f}"` 展开后看到 `FString::ApplyFormat((value), "0.2f")`，调用时根据 `value` 的实际类型选择重载：

```text
value 类型               -> 选中的重载
==============================================================
int32 / uint32 / ... 8 类整型  -> ApplyFormatInteger<T, IsUnsigned, UT>
float32 / float64              -> ApplyFormatFloat<T>
bool                            -> ApplyFormatBool
FString                         -> ApplyFormatString
其他 (枚举 / UObject / 自定义类型) -> ApplyFormat (通配版本, 通过 TypeId 反射)
```

### 4.3 通配版本 `ApplyFormat(?& Value, ...)`

```cpp
static FString ApplyFormat(void* ValuePtr, int TypeId, const FString& Specifier)
{
    FFormatSpecifier Spec(Specifier);
    FString OutStr;

    asITypeInfo* TypeInfo = FAngelscriptEngine::Get().Engine->GetTypeInfoById(TypeId);

    // 特殊处理: 枚举类型
    if (TypeInfo != nullptr && (TypeInfo->GetFlags() & asOBJ_ENUM) != 0)
    {
        if (Spec.Type == 'n')           // ':n' 类型说明符 -> 输出枚举名
        {
            UUserDefinedEnum* UnrealEnum = (UUserDefinedEnum*)TypeInfo->GetUserData();
            if (UnrealEnum != nullptr)
                OutStr = UnrealEnum->GetNameStringByValue(*(uint8*)ValuePtr);
            else
            {
                // 仅 :n 模式打印枚举名, 否则打印数值
                asUINT EnumCount = TypeInfo->GetEnumValueCount();
                for(asUINT i = 0; i < EnumCount; ++i)
                {
                    int EnumValue;
                    const char* ValueName = TypeInfo->GetEnumValueByIndex(i, &EnumValue);
                    if (EnumValue == *(uint8*)ValuePtr && ValueName != nullptr)
                    {
                        OutStr = ANSI_TO_TCHAR(ValueName);
                        break;
                    }
                }
            }
        }
        else
        {
            // 非 :n -> 输出枚举数值
            OutStr = FString::FromInt(*(uint8*)ValuePtr);
        }
    }
    // ... 其他类型走通用 ToString 路径 ...
}
```

### 4.4 类型未支持时的兜底

如果 `value` 是 AS 自定义 struct 或 UObject 等通配版本无法识别的类型，调用 `FString::ApplyFormat` 会失败（运行时抛异常或返回空字符串）。**最佳实践**：在 f-string 中只对**已被 ApplyFormat 重载明确支持的类型**使用格式说明符；对自定义类型用普通 `{}` 或先 `.ToString()` 再插值。

### 4.5 与 `Append` 的协作

f-string 展开为 `.Append(...)` 链式调用——这要求所有出现在 `{...}` 中的表达式类型都有对应的 `FString.opAddAssign(T)` 或 `Append(T)` 重载。Bind_FString.cpp 中暴露的 Append 重载覆盖：

```text
.Append(const FString&)     - 字符串本身
.Append(int32 / int64 / ...)  - 整型
.Append(float32 / float64)    - 浮点
.Append(bool)                  - 布尔
.Append(const FName&)          - FName
.Append(const FText&)          - FText
.AppendChar(int16)             - 单字符
... (详见 Bind_FString.cpp Append 系列绑定)
```

未被 `Append` 直接支持的类型，`{value}` 形式（无 spec、无 `=`）展开后会编译失败——AS 编译器会报"找不到匹配的 `Append` 重载"。这反过来约束了 f-string 的类型安全：**未支持的类型在编译期就被拦截**。

---

## 五、`FFormatSpecifier` —— 格式说明符状态机

**源码所在**：`Bind_FString.cpp:590-877`。

### 5.1 数据结构

```cpp
struct FFormatSpecifier
{
    enum class EAlign : uint8
    {
        None,           // 无对齐
        Left,           // '<' 左对齐
        Right,          // '>' 右对齐
        Middle,         // '^' 居中对齐
        AfterSign,      // '=' 符号后填充 (如 0 填充)
    };
    EAlign Align = EAlign::None;

    enum class ESign : uint8
    {
        Both,           // '+' 总是显示符号
        Negative,       // 默认: 仅负数显示符号
        LeadingSpace,   // ' ' 正数前导空格代替 '+'
    };
    ESign Sign = ESign::Negative;

    bool    bPrefixBase = false;        // '#' 显示进制前缀 (0x / 0b / 0o)
    bool    bCommas      = false;       // ',' 千分位逗号
    FString MinimumWidth;               // 最小宽度
    FString Precision;                   // 精度

    TCHAR Fill = ' ';                    // 填充字符 (默认空格, '0' 对齐时变 '0')
    TCHAR Type = ' ';                    // 类型字符 (d/x/X/b/c/o/n/e/E/f/F/g/G/%)
};
```

### 5.2 解析状态机

`FFormatSpecifier(const FString& Specifier)` 构造函数实现 5 阶段状态机：

```text
EState 状态:
  OnStart        -> OnSign        -> OnAlternateForm -> OnMinimumWidth
                                                    -> OnPrecision -> OnType

字符 -> 状态转换:
  '<' / '>' / '^' / '='  -> Align + 进入 OnSign  (前置字符变成 Fill)
  '+' / '-' / ' '         -> Sign + 进入 OnAlternateForm (仅 OnSign 阶段)
  '#'                      -> bPrefixBase + 进入 OnMinimumWidth (仅 OnAlternateForm 阶段)
  '0'-'9'                  -> 数字累积
                              首位 '0' 且没有 MinimumWidth -> Align=AfterSign, Fill='0'
                              在 OnMinimumWidth 阶段 -> 累积到 MinimumWidth
                              在 OnPrecision 阶段 -> 累积到 Precision
  '.'                      -> 进入 OnPrecision 阶段
  ','                      -> bCommas = true (任何阶段)
  'd' 'x' 'X' 'b' 'c' 'o' 'n' 'e' 'E' 'f' 'F' 'g' 'G' '%'  -> Type = 该字符
```

### 5.3 完整说明符语法

```text
[<fill_char>][<>=^][+- ][#][0][<width>][,][.<precision>][<type>]
   ↑          ↑     ↑    ↑   ↑    ↑      ↑      ↑           ↑
   填充       对齐  符号  前缀 0填充 宽度  千分位  精度      类型
```

各字段含义：

| 字段 | 取值 | 含义 | 示例 |
|------|------|------|------|
| **fill_char** | 任意字符 | 对齐时的填充字符（默认 ` `）| `*<10` 用 `*` 填充 |
| **align** | `<` `>` `^` `=` | 对齐方式：左/右/居中/符号后 | `<10` 左对齐宽 10 |
| **sign** | `+` `-` ` ` | 符号显示策略 | `+0.2f` 总是显示符号 |
| **#** | `#` | 显示进制前缀（仅 `b/x/X/o`）| `#x` 输出 `0x...` |
| **0** | `0` | 0 填充（自动设置 `Align=AfterSign, Fill='0'`）| `05d` 等价于 `0=5d` |
| **width** | 数字 | 最小宽度 | `10` 至少 10 字符 |
| **,** | `,` | 千分位逗号分隔 | `,d` 输出 `1,234,567` |
| **.precision** | `.` + 数字 | 精度（浮点小数位 / 字符串截断）| `.2f` 保留 2 位小数 |
| **type** | `d/x/X/b/c/o/n/e/E/f/F/g/G/%` | 类型说明 | `0.2f` 浮点格式 |

### 5.4 类型说明符（Type）一览

| Type | 含义 | 适用类型 | 示例 |
|------|------|---------|------|
| `d` | 十进制整数 | 整型 | `42` |
| `x` | 十六进制小写 | 整型 | `2a` |
| `X` | 十六进制大写 | 整型 | `2A` |
| `b` | 二进制 | 整型 | `101010` |
| `c` | 字符 | 整型（视为 ASCII / Unicode 码点）| `*` |
| `o` | 八进制 | 整型 | `52` |
| `n` | 本地化数字（千分位）| 数值 | `1,234,567` |
| `e` | 科学计数法（小写）| 浮点 | `1.234e+02` |
| `E` | 科学计数法（大写）| 浮点 | `1.234E+02` |
| `f` | 定点表示 | 浮点 | `123.456` |
| `F` | 定点表示（大写 INF/NAN）| 浮点 | `INF` / `NAN` |
| `g` | 通用（自动 e/f）| 浮点 | `123.456` 或 `1.234e+10` |
| `G` | 通用（大写）| 浮点 | `1.234E+10` |
| `%` | 百分比（×100 + `%`）| 浮点 | `50.000%` |

特殊：**枚举类型** `:n` 输出枚举名（如 `EState::Active`），其他类型说明符则输出枚举数值。

### 5.5 完整说明符示例

| 说明符 | 含义 | `42` 的输出 |
|-------|------|------------|
| `(无)` | 默认 | `42` |
| `5d` | 十进制宽 5（默认右对齐空格填充） | `   42` |
| `05d` | 十进制宽 5，0 填充 | `00042` |
| `<5d` | 左对齐宽 5 | `42   ` |
| `>5d` | 右对齐宽 5 | `   42` |
| `^5d` | 居中宽 5 | ` 42  ` |
| `*<5d` | 左对齐宽 5，`*` 填充 | `42***` |
| `+d` | 总是显示符号 | `+42` |
| `,d` | 千分位逗号（`1234567`）| `1,234,567` |
| `#x` | 十六进制带前缀 | `0x2a` |
| `#b` | 二进制带前缀 | `0b101010` |

浮点示例（`3.14159`）：

| 说明符 | 输出 |
|-------|------|
| `f` | `3.14159` |
| `0.2f` | `3.14` |
| `+0.2f` | `+3.14` |
| `10.4f` | `    3.1416` |
| `010.4f` | `00003.1416` |
| `e` | `3.141590e+00` |
| `.2%` | `314.16%` |
| `,.2f` | （千分位 + 2 位小数, 1234567.89 → `1,234,567.89`）|

### 5.6 各 ApplyFormat 重载的差异

| 重载 | 特殊处理 |
|------|---------|
| `ApplyFormatInteger<T, IsUnsigned, UT>` | `Spec.Type` 决定进制；`#` 前缀；`,` 千分位（`InsertCommas`）；`+` `-` ` ` 符号；`AfterSign` 对齐用 `0` 填充 |
| `ApplyFormatFloat<T>` | `Spec.Type` 在 `f/e/g/n/%` 间切换；`.precision` 决定小数位；`%` 类型自动 `*100` 并追加 `%` |
| `ApplyFormatBool` | 输出 `true` / `false`（不支持任何类型说明符）；可用对齐 + 宽度 |
| `ApplyFormatString` | 仅支持对齐 + 宽度（`<10` / `>10` / `^10`）；不支持 type / precision |
| `ApplyFormat(?&)` 通配 | 枚举特殊：`:n` 输出名字，否则输出数值 |

---

## 六、类型支持与扩展性

### 6.1 自动支持的类型

f-string `{value}` 形式下（无 spec / 无 `=`），任何能被 `FString::Append(T)` 接受的类型都可直接插值：

```text
基础类型: int8/16/32/64, uint8/16/32/64, float32/64, bool
UE 字符串: FString, FName, FText
AS 字符串: const char* (字面量)
任意有 .ToString() 方法的类型 (需手动: f"...{obj.ToString()}...")
```

### 6.2 带格式说明符的类型

`{value:spec}` 形式下，必须有匹配的 `ApplyFormat` 重载：

```text
明确支持: int8/16/32/64, uint8/16/32/64, float32/64, bool, FString
通配兜底: 枚举类型 (通过 ?& 重载, 仅 :n 类型说明符有效)
不支持: AS 自定义 struct / UObject 等 -> 编译期或运行期报错
```

### 6.3 自描述模式 `{x=}`

```text
任何类型都可用 {x=} 形式 (展开为 "x = "+(x))
唯一要求: x 类型支持 FString.opAdd(T) 或与 FString 的连接运算符
```

### 6.4 扩展自定义类型支持

添加自定义类型的 `ApplyFormat` 支持需要在 C++ 端扩展 `Bind_FString.cpp`：

```cpp
// 例: 给 FVector 添加 ApplyFormat 支持
static FString ApplyFormatVector(const FVector& V, const FString& Specifier)
{
    FFormatSpecifier Spec(Specifier);
    // 自定义格式: ":xyz" 输出 "(X, Y, Z)", ":mag" 输出长度等
    return FString::Printf(TEXT("(%.2f, %.2f, %.2f)"), V.X, V.Y, V.Z);
}

FAngelscriptBinds::BindGlobalFunction(
    "FString ApplyFormat(const FVector& Value, const FString& Specifier)",
    &ApplyFormatVector);
```

注意 AS 重载查找顺序：**精确类型 > 引用类型 > 通配 `?&`**。`FVector` 自定义版本会优先于通配兜底命中。

---

## 七、完整链路 ASCII 全景

下图以 `f"Player {Name} has {Health:0.2f} HP, {Coins:,} coins, {State=}"` 为例展示从源码到运行时的端到端流程：

```text
============================================================================
  f-string 完整生命周期 (展开期 -> 编译期 -> 运行期)
============================================================================

[.as 源文件]
    Print(f"Player {Name} has {Health:0.2f} HP, {Coins:,} coins, {State=}");
        |
        | [Phase 1] 词法识别 (ParseIntoChunks)
        |
        | case 'f' 触发 (ChunkEnd 处):
        |   - !bInComment && !bInString
        |   - IsStartOfIdentifier()
        |   - RawCode[ChunkEnd+1] == '"'
        |   -> FormatStringStart = ChunkEnd
        |
        | 后续 case '"' 闭合时:
        |   - bInString 翻转为 false
        |   - FormatStringStart != -1 触发 GenerateFormatString
        v
GenerateFormatString(FFile&, "Player {Name} has {Health:0.2f} HP, {Coins:,} coins, {State=}")
    |
    | [Step 1] 主循环字符级扫描 + 状态机
    |
    +-- 字面量 "Player " (StartPosition=0, CurPosition=7)
    |     -> Result += .Append("Player ")
    +-- '{' Name '}' (CurPosition=8..13)
    |     -> 进入 bInExpression
    |     -> 退出时 ParseFormatExpression("Name") -> "Name"
    |     -> Result += .Append(Name)
    +-- 字面量 " has "
    |     -> Result += .Append(" has ")
    +-- '{' Health:0.2f '}'
    |     -> ParseFormatExpression("Health:0.2f")
    |        -> 从右扫描: 'f' '2' '.' '0' (合法 spec 字符)
    |        -> ':' 触发 -> Specifier="0.2f", Pos-1 != '='
    |        -> 返回 'FString::ApplyFormat((Health), "0.2f")'
    |     -> Result += .Append(FString::ApplyFormat((Health), "0.2f"))
    +-- 字面量 " HP, "
    +-- '{' Coins:, '}' -> .Append(FString::ApplyFormat((Coins), ","))
    +-- 字面量 " coins, "
    +-- '{' State= '}'
    |     -> ParseFormatExpression("State=")
    |        -> 从右扫描: '=' (bFoundFormat=false) -> EqualsPos=5
    |        -> 继续向左, 'e' 不是合法 spec 字符 -> bFoundFormat=true
    |        -> 实际此分支无效 (因为 'e' 是合法字符 'e' / 'E', 但...)
    |        -> 注意: 实际算法中扫描 'State=' 时:
    |             Pos=5 ('=') -> EqualsPos=5
    |             Pos=4 ('e') -> bFoundFormat=true, 'e' 是合法 spec 字符 -> 继续
    |             Pos=3 ('t') -> 't' 不是合法 -> 终止扫描
    |        -> 没找到 ':', EqualsPos != -1 -> "\"State = \"+(State)"
    |     -> Result += .Append("State = "+(State))
    +-- 字面量 "" (空)
    |
    | [Step 2] 包裹外层括号
    |
    v
"(FString().Append(\"Player \").Append(Name).Append(\" has \")
           .Append(FString::ApplyFormat((Health), \"0.2f\")).Append(\" HP, \")
           .Append(FString::ApplyFormat((Coins), \",\")).Append(\" coins, \")
           .Append(\"State = \"+(State)))"
        |
        | [Step 3] PendingReplaces 入队 + 末尾批量替换源码
        v
[源码就地改写]
    Print((FString().Append("Player ").Append(Name) ... .Append("State = "+(State))));
        |
        | [Phase 2] AS 编译器编译 (完全无视 f-string)
        v
asCScriptFunction (Print 调用 + FString 链式 Append + ApplyFormat 调用)
        |
        | [Phase 3] 类生成 / 模块加载
        v
UFunction (Print) + 编译完成的字节码
        |
        | [Phase 4] 运行时
        v
执行 .Append("Player ") -> FString = "Player "
执行 .Append(Name)        -> FString = "Player Hero"
执行 .Append(" has ")     -> FString = "Player Hero has "
执行 FString::ApplyFormat((Health), "0.2f")
    -> ApplyFormatFloat<float> (依赖 Health 实际类型)
        -> FFormatSpecifier("0.2f")
            -> Type='f', Precision="2"
        -> FString::Printf("%.*f", 2, AbsValue) = "100.00"
        -> AlignString / Sign 处理
    -> 返回 "100.00"
执行 .Append("100.00")    -> FString = "Player Hero has 100.00"
执行 .Append(" HP, ")     -> FString = "Player Hero has 100.00 HP, "
执行 FString::ApplyFormat((Coins), ",")
    -> ApplyFormatInteger<int32, false, uint32>
        -> FFormatSpecifier(",") -> bCommas=true
        -> "1234567" -> InsertCommas -> "1,234,567"
执行 .Append("1,234,567") -> FString = "Player Hero has 100.00 HP, 1,234,567"
执行 .Append(" coins, ")
执行 .Append("State = "+(State))
    -> "State = " + State.ToString() (或 enum 转换)
    -> "State = Active"
执行 .Append("State = Active")
        |
        v
最终 FString: "Player Hero has 100.00 HP, 1,234,567 coins, State = Active"
传给 Print()
```

---

## 八、修饰符与说明符速查表

### 8.1 f-string 语法速查

```text
基础形式
================================================================
f""                         空字符串
f"text"                     纯文本
f"{expr}"                   插入表达式 (调用 .Append)
f"{expr:spec}"              带格式说明符 (调用 ApplyFormat)
f"{expr=}"                  自描述: "expr = " + (expr)
f"{expr=:spec}"             自描述 + 格式: "expr = " + ApplyFormat(...)

转义
================================================================
f"{{"                       字面 '{'
f"}}"                       字面 '}'

容错
================================================================
f"{}"                       空表达式 -> 静默跳过
f"{ unclosed"               未闭合 -> 编译期报错 (生成不平衡代码)
跨行 f-string                行尾自动重置 -> 不支持
跨 chunk f-string            FormatStringStart < ChunkStart 防御 -> 不支持
```

### 8.2 格式说明符完整语法

```text
[<fill>][<>=^][+-空格][#][0][<width>][,][.<precision>][<type>]
                                                       ↑
[fill]              填充字符 (任意, 默认 ' '), 仅对齐时生效
[align]             < 左, > 右, ^ 中, = 符号后填充
[sign]              + 总显示, - 仅负数, 空格 正数前导空格
[#]                 显示进制前缀 (0x / 0b / 0o)
[0]                 0 填充 (隐含 = 对齐 + Fill='0')
[width]             最小宽度 (整数)
[,]                 千分位逗号
[.precision]        浮点小数位 / 字符串截断
[type]              d/x/X/b/c/o/n/e/E/f/F/g/G/% 之一
```

### 8.3 类型说明符速查

| Type | 含义 | 示例输入 → 输出 |
|------|------|--------------|
| `d` | 十进制整数 | `42` → `42` |
| `x` | 十六进制小写 | `255` → `ff` |
| `X` | 十六进制大写 | `255` → `FF` |
| `b` | 二进制 | `42` → `101010` |
| `c` | 字符 | `42` → `*` |
| `o` | 八进制 | `42` → `52` |
| `n` | 本地化（千分位 + 自动）| `1234567` → `1,234,567` |
| `e` | 科学计数法（小写）| `3.14` → `3.140000e+00` |
| `E` | 科学计数法（大写）| `3.14` → `3.140000E+00` |
| `f` / `F` | 定点表示 | `3.14159` → `3.141590` |
| `g` / `G` | 通用（自动 e/f）| 自动选择 |
| `%` | 百分比（×100 + `%`）| `0.5` → `50.000000%` |
| `:n`（枚举）| 枚举名 | `EState::Active` → `"Active"` |

### 8.4 4 个常见用例

```text
[日志格式化]
    Log(f"Player {Name} took {Damage} damage from {Source.Name}");

[调试自描述]
    Print(f"{Health=}, {Mana=}, {Position.X=:0.2f}");
    // 输出: "Health = 100, Mana = 50, Position.X = 12.34"

[对齐表格]
    Print(f"{Name:<20} | {Score:>10,} | {Time:0.2f}");
    // 输出: "Hero                 |      1,234 | 12.34"

[十六进制 + 前缀]
    Print(f"Address: {Ptr:#018x}");
    // 输出: "Address: 0x00007ff8a3b40000"
```

### 8.5 关键限制速览

| 限制 | 来源 | 说明 |
|------|------|------|
| 必须同行内闭合 | `case '\n'` 行尾重置 | 跨行 f-string 不支持 |
| 必须同 chunk 内闭合 | `FormatStringStart >= ChunkStart` 防御 | 跨 chunk 不支持 |
| `f` 必须是标识符起点 | `IsStartOfIdentifier()` 检查 | `xf"..."` 不识别 |
| `f` 紧跟 `"` | `RawCode[ChunkEnd+1] == '"'` | `f "..."`（中间空格）不识别 |
| 嵌套 `{` 不支持 | 进入表达式后 `{` 字符被忽略 | `f"{ {nested} }"` 行为不确定 |
| `Math::Pi` 类含 `::` 表达式 | 状态机扫描遇 `i` 终止 | 不会误识别为 spec |
| 表达式中含 `:` 的需谨慎 | `if/then/else` 等 | 用 `(...)` 包裹避免误识 |
| 自定义类型 spec | 必须有对应 `ApplyFormat` 重载 | 否则运行时报错 |
| 单独 `}` | 静默吞掉 | 输出可能丢字符 |

---

## 九、设计哲学

### 9.1 为什么走预处理器展开而非 AS 内核扩展？

```text
+ 优势:
  - AS 内核 (ThirdParty/angelscript) 完全无需改动, 上游 fork 容易维护
  - 调试时 AS 字节码看到的就是普通 .Append 链式, 行号映射干净
  - 可以利用 AS 现有的运算符重载 / 函数重载机制
  - 类型安全自然继承 (Append 不支持的类型在编译期就报错)

- 代价:
  - 错误信息指向展开后的代码, 而非源 f-string (调试需要心智映射)
  - 不能跨行 / 跨 chunk
  - 无法直接做编译期常量优化 (展开后的链式表达式得运行期才能拼)
```

### 9.2 为什么 ApplyFormat 用 12 个重载而非单一通配？

```cpp
ApplyFormat(int32, ...)     // 重载 1
ApplyFormat(uint32, ...)    // 重载 2
// ... 10 个明确类型
ApplyFormat(?&, ...)         // 通配兜底
```

**原因 1**：AS 的重载查找优先匹配精确类型 > 通配引用，**性能更好**（避免每次调用都走通配版本的 TypeId 反射）。

**原因 2**：明确类型版本可以用 C++ 模板 + 内联优化（`ApplyFormatInteger<T>` / `ApplyFormatFloat<T>`），生成的代码更紧凑。

**原因 3**：通配版本作为兜底处理**无法明确支持的类型**（如自定义枚举），保证不会出现"类型未注册导致编译失败"的边缘情况。

### 9.3 为什么从右向左扫描格式说明符？

`{Math::Pi:0.4f}` 类表达式中，`:` 既可以是命名空间分隔符，也可以是说明符分隔符。**从右扫描的关键洞察**：

```text
说明符总是表达式末尾的连续合法字符
-> 从右扫描遇到第一个非合法字符时立即终止
-> 此前如果碰到 ':', 那就是说明符分隔
-> 否则整个 FormatExpr 都是表达式
```

这避免了"维护表达式括号深度 + 上下文敏感解析"的复杂度——一个简单的字符分类查表就能正确处理 99% 场景，剩余边缘情况（如 `?:` 三元表达式中带 spec）需要用户用 `(...)` 包裹明确边界。

### 9.4 为什么 `0` 既是宽度数字又触发 `AfterSign` 对齐？

```python
# Python 的设计:
f"{42:05d}"  # -> "00042"  (0 填充, 宽度 5)
f"{42:5d}"   # -> "   42"  (空格填充, 宽度 5)
```

代码：

```cpp
case '0' ... '9':
    if (State <= EState::OnMinimumWidth)
    {
        if (MinimumWidth.Len() == 0 && Char == '0')
        {
            Align = EAlign::AfterSign;       // 0 在最前面 -> 隐含 AfterSign 对齐
            Fill = '0';
        }
        // 累积到 MinimumWidth
    }
break;
```

**设计意图**：模仿 C `printf` / Python 等主流格式化语法，让 `0<width>d` 是"零填充 + 宽度"的简写，避免每次都写 `0=<width>d`。

### 9.5 为什么自描述 `{x=}` 输出 `"x = "+(x)` 而不是 `"x = "+x`？

```cpp
return FString::Printf(TEXT("\"%s = \"+(%s)"), *Expr, *Expr);
//                                  ↑↑↑
//                              注意外层括号
```

**原因**：保留运算符优先级。`{a + b=}` 展开后如果是 `"a + b = "+a + b`，会因为 `+` 左结合性变成 `("a + b = "+a) + b` —— 第一项是字符串，但第二项 `b` 又得加到上面，可能改变语义。加 `(expr)` 强制把整个表达式作为单元处理：`"a + b = "+(a + b)`。

---

## 十、关键结论速查

| 主题 | 结论 |
|------|------|
| **f-string 不是 AS 关键字** | 完全是预处理器层面的字符串字面量识别 + 代码展开，AS 内核对 f-string **完全无感知** |
| **核心入口** | `AngelscriptPreprocessor.cpp:3813` `case 'f'` 词法识别 + L1970 `GenerateFormatString` 主流程 + L2067 `ParseFormatExpression` 单表达式解析 |
| **5 个识别条件** | 至少剩 3 字符 + 不在注释 / 字符串内 + `IsStartOfIdentifier()` + 紧跟 `"` |
| **展开模式** | `(FString().Append("...").Append(expr).Append(FString::ApplyFormat((expr), "spec")))` 链式 |
| **3 种 `{...}` 解析产物** | ① 纯表达式 → `expr`；② 带 spec → `FString::ApplyFormat((expr), "spec")`；③ 自描述 → `"expr = "+(expr)` 或 `"expr = "+FString::ApplyFormat(...)` |
| **从右向左扫描** | 优先识别说明符，遇到非合法 spec 字符立即终止——避免与表达式中的 `:` 冲突 |
| **运行时绑定** | `Bind_FString.cpp:1300-1313` 提供 12 个 `ApplyFormat` 重载（8 整型 + 2 浮点 + 1 bool + 1 FString + 1 通配 `?&`）|
| **格式说明符状态机** | 5 阶段 EState（OnStart → OnSign → OnAlternateForm → OnMinimumWidth → OnPrecision → OnType），全字符级解析 |
| **完整说明符语法** | `[fill][align][sign][#][0][width][,][.precision][type]` |
| **类型说明符** | `d/x/X/b/c/o/n/e/E/f/F/g/G/%` 共 14 个；枚举的 `:n` 输出名字 |
| **类型扩展** | 自定义类型可通过添加 `ApplyFormat(const T&, const FString&)` 全局函数扩展（精确类型重载优先于通配） |
| **类型安全继承自 Append** | `{value}` 形式下 value 必须有 `Append` 重载，否则编译期报错 |
| **限制** | 不支持跨行 / 跨 chunk / 嵌套 `{}` / 含 `::` 表达式需小心 |
| **转义** | `{{` → `'{'`，`}}` → `'}'`；通过 `.AppendChar('{')` 实现 |
| **空 f-string** | `f""` 展开为 `(FString())` |
| **错误集中点** | ① 未闭合 `{` → 末尾 `bInExpression=true` 导致代码不平衡 → AS 编译报错；② 自定义类型用 spec → 运行时找不到 ApplyFormat 重载报错；③ `{ {nested} }` 嵌套 → 行为未定义；④ 跨行 f-string → 行尾静默重置, 后续字符被当普通字符处理 |

---

## 十一、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` — `default` 语句（共享预处理器代码生成模式）
  - `Documents/Knowledges/ZH/Syntax_DelegateEvent.md` — `delegate` / `event`（同样走预处理器代码展开）
  - `Documents/Knowledges/ZH/Syntax_UPROPERTY.md` / `Syntax_UFUNCTION.md` — UPROPERTY / UFUNCTION 修饰符（共享 `ParseIntoChunks` 词法器）
- 核心实现：
  - `Bind_FString.cpp` — `FString` 完整绑定（含 `ApplyFormat` 12 重载与 `FFormatSpecifier` 状态机）
  - `AngelscriptPreprocessor.cpp` — 预处理器主流程
- 架构与运行时（待写）：
  - `Documents/Knowledges/ZH/Type_Preprocessor.md` — 预处理器整体架构

---

## 十二、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-28 | 首版：基于当前项目实际源码（`AngelscriptPreprocessor.cpp:1970-2161, 3813-3823, 3941-3957` / `Bind_FString.cpp:590-1313`）完整产出。覆盖：① 4 阶段管线总览（词法识别 → GenerateFormatString → ParseFormatExpression → 运行时 ApplyFormat）；② `case 'f'` 词法识别 5 个条件 + `case '"'` 终点触发 + 行尾 / chunk 边界防御；③ `GenerateFormatString` 主循环字符级状态机 + `{` `}` 双分支处理 + `{{` `}}` 转义 + 容错策略；④ `ParseFormatExpression` 从右向左扫描 + 三种产物形式（纯表达式 / 自描述 / 带 spec / 自描述+spec）+ `=` 优先级与 `:` 边界检测；⑤ 运行时 12 个 `ApplyFormat` 重载（8 整型 + 2 浮点 + 1 bool + 1 FString + 1 通配 `?&`）+ AS 重载选择规则 + 通配兜底中枚举特殊处理；⑥ `FFormatSpecifier` 5 阶段状态机（OnStart/OnSign/OnAlternateForm/OnMinimumWidth/OnPrecision/OnType）+ 完整说明符语法 + 14 个类型说明符；⑦ 类型支持矩阵 + 自定义类型扩展指南；⑧ 4 个常见用例 + 9 项关键限制；⑨ 5 个设计哲学解析（预处理器 vs 内核扩展、12 重载 vs 单通配、从右向左扫描、`0` 双语义、`(expr)` 优先级保护）。本文未引用 Hazelight 参考文档（无 Temp 文档），全程基于当前项目源码事实。所有 ASCII 图遵循纯 ASCII 风格（与 `Syntax_DefaultStatement.md` v1.3 / `Syntax_UPROPERTY.md` v1.3 / `Syntax_UFUNCTION.md` v1.1 / `Syntax_DelegateEvent.md` v1.0 / `Syntax_DefaultComponent.md` v1.0 统一）。 |

