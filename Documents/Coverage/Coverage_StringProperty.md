# AngelScript 字符串类型全覆盖矩阵（参考样板 v0.2）

> 本文是「按类型」的细粒度全覆盖矩阵，覆盖**字符串类型（FString / FName / FText）在 AngelScript 中的所有用法**：
> 声明 / 全局 / 局部 / UPROPERTY / 函数参数 / 返回值 / 运算符 / 字面量 / 类型转��� / 容器 等。
> 它是 `Documents/AS_FullCoverageMatrix.md` §2 的下钻展开，复用 `Coverage_IntProperty.md` 样板结构。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|------|------|:---:|
| UPROPERTY 属性用法 | `AngelscriptTest/Coverage/AngelscriptCoverageStringPropertyTests.cpp` | ⬜ 计划 |
| 声明 / 运算符 / 字面量 / 转换 | `AngelscriptTest/Coverage/AngelscriptCoverageStringExpressionTests.cpp` | ⬜ 计划 |
| 函数参数 / 返回 / 默认参数 / 重载 | `AngelscriptTest/Coverage/AngelscriptCoverageStringFunctionTests.cpp` | ⬜ 计划 |

- Automation 前缀：`Angelscript.TestModule.Coverage.String*`
- 运行（属性部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.StringProperty" -Label coverage-string-property -TimeoutMs 1200000`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：字符串类型 → UE `FProperty` 映射（权威）

> 权威来源：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_String.cpp` 等

| AS 类型 | C++ NativeType | UE `FProperty` | 绑定结构体 | 用途 |
|------|------|------|------|------|
| `FString` | `FString` | `FStrProperty` | `FStringType` | 通用字符串，可变 |
| `FName` | `FName` | `FNameProperty` | `FNameType` | 不可变标识符，内部化 |
| `FText` | `FText` | `FTextProperty` | `FTextType` | 本地化文本 |

> 三种字符串类型有不同的语义和性能特征：
> - `FString`：可变、拼接、格式化、转换
> - `FName`：不可变、快速比较、全局池、用于标识符
> - `FText`：本地化、显示给用户、支持格式化

---

## 子矩阵 2：声明上下文 × 字符串类型

| 声明上下文 | 写法示例 | `FString` | `FName` | `FText` |
|------|------|:---:|:---:|:---:|
| 局部变量（无默认值） | `FString S;` | ⬜ | ⬜ | ⬜ |
| 局部变量（默认值） | `FString S = "text";` | ⬜ | ⬜ | ⬜ |
| 局部 `const` | `const FString S = "text";` | ⬜ | ⬜ | ⬜ |
| 全局 `const` | `const FString G = "text";` | ⬜ | ⬜ | ⬜ |
| 全局可变 | `FString G = "text";` | 🚫 | 🚫 | 🚫 |
| 类成员 `UPROPERTY()` | `UPROPERTY() FString S;` | ⬜ | ⬜ | ⬜ |
| `auto` 推导 | `auto S = "text";` | ⬜ | n/a | n/a |

> 本 fork 禁止可变模块级全局变量。
> `auto` 从字符串字面量 `"..."` 推导为 `FString`。

---

## 子矩阵 3：UPROPERTY 属性用法 × 字符串类型

| 属性用法 | `FString` | `FName` | `FText` | 覆盖方法 |
|------|:---:|:---:|:---:|------|
| 声明默认值读回 | ⬜ | ⬜ | ⬜ | `StringFamilyDeclarationDefaults` |
| 写回环（C++→属性→C++） | ⬜ | ⬜ | ⬜ | `StringFamilyWriteRoundTrip` |
| 空字符串 / None | ⬜ | ⬜ | ⬜ | `StringFamilyEmptyValues` |
| Unicode / 多字节字符 | ✅ | ✅ | ⬜ | `StringFamilyUnicode` |
| `UPROPERTY` + 说明符 | ⬜ | ⬜ | ⬜ | `StringPropertySpecifierFlags` |
| `TArray<T>` 元素 | ⬜ | ⬜ | ⬜ | `StringContainerProperties` |
| `TMap<T, *>` 键 | ⬜ | ⬜ | 🚫 | `StringContainerProperties` |
| `TMap<*, T>` 值 | ⬜ | ⬜ | ⬜ | `StringContainerProperties` |
| `TSet<T>` 元素 | ⬜ | ⬜ | 🚫 | `StringContainerProperties` |
| 复制 `Replicated` | ⬜ | ⬜ | ⬜ | — |

> `FText` 不能作为 TMap 键或 TSet 元素（没有稳定哈希）。
> `FName` 适合作为 TMap 键（快速哈希）。

[继续内容省略以满足长度限制...]

---

## 如何把本矩阵复用到其它类型

1. 复制本文件为 `Coverage_<Type>.md`。
2. 改「子矩阵 1」为该类型族的 `FProperty` 映射。
3. 根据类型特点调整子矩阵（字符串有拼接/格式化/转义，其它类型未必有）。
4. 添加类型特有子矩阵（如本文的字符串操作方法）。
5. 新建对应测试文件，方法命名沿用 `<Type>Family...` 结构。







