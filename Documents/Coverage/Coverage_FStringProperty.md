# AngelScript `FString` 全覆盖矩阵

> 本文是「按类型」的细粒度全覆盖矩阵，覆盖**FString 在 AngelScript 中的所有用法**：
> 声明 / 全局 / 局部 / UPROPERTY / 函数参数 / 返回值 / 运算符 / 字面量 / 方法 / 转换 / 容器 等。
> 基于 `Coverage_IntProperty.md` 和 `Coverage_FloatProperty.md` 样板。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|------|------|:---:|
| UPROPERTY 属性用法 | `AngelscriptTest/Coverage/AngelscriptCoverageFStringPropertyTests.cpp` | 待建 |
| 声明 / 运算符 / 字面量 / 转换 | `AngelscriptTest/Coverage/AngelscriptCoverageFStringExpressionTests.cpp` | 待建 |
| 函数参数 / 返回 / 默认参数 / 重载 | `AngelscriptTest/Coverage/AngelscriptCoverageFStringFunctionTests.cpp` | 待建 |
| 方法测试 | `AngelscriptTest/Coverage/AngelscriptCoverageFStringMethodTests.cpp` | 待建 |

- Automation 前缀：`Angelscript.TestModule.Coverage.FString*`
- 运行命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FString" -Label coverage-fstring -TimeoutMs 1200000`

## 图例

- `✅ 已覆盖 ✅ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：String 类型 → UE `FProperty` 映射（权威）

> 权威来源：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp`, `Bind_FName.cpp`, `Bind_FText.cpp`

| AS 类型 | C++ NativeType | UE `FProperty` | 绑定结构体 | 用途 |
|------|------|------|------|------|
| `FString` | `FString` | `FStrProperty` | `FStringType` | 可变字符串 |
| `FName` | `FName` | `FNameProperty` | `FNameType` | 不可变标识符 |
| `FText` | `FText` | `FTextProperty` | `FTextType` | 本地化文本 |

> String 家族有 3 种类型，用途不同。

---

## 子矩阵 2：声明上下文 × String 家族

> 「String 出现在哪里」。覆盖归属：UPROPERTY 行 → Property 测试；其余 → Expression/Function 测试。

| 声明上下文 | 写法示例 | `FString` | `FName` | `FText` |
|------|------|:---:|:---:|:---:|
| 局部变量（无默认值） | `FString X;` | ⬜ | ⬜ | ⬜ |
| 局部变量（默认值） | `FString X = "Hello";` | ⬜ | ⬜ | ⬜ |
| 局部 `const` | `const FString X = "Hello";` | ⬜ | ⬜ | ⬜ |
| 全局 `const` | `const FString G = "Global";` | ⬜ | ⬜ | ⬜ |
| 全局可变 | `FString G = "Global";` | 🚫 | 🚫 | 🚫 |
| 类成员（无 UPROPERTY，脚本可见） | `FString X;` | ⬜ | ⬜ | ⬜ |
| 类成员 `UPROPERTY()` | `UPROPERTY() FString X;` | ⬜ | ⬜ | ⬜ |

> 本 fork 禁止可变模块级全局变量。

---

## 子矩阵 3：UPROPERTY 属性用法 × String 家族

> 覆盖归属：`AngelscriptCoverageFStringPropertyTests.cpp`。

| 属性用法 | `FString` | `FName` | `FText` | 覆盖方法 |
|------|:---:|:---:|:---:|------|
| 声明默认值读回 | ⬜ | ⬜ | ⬜ | — |
| 写回环（C++→属性→C++） | ⬜ | ⬜ | ⬜ | — |
| 空字符串 | ⬜ | ⬜ | ⬜ | — |
| 特殊字符（换行/引号/Unicode） | ⬜ | ⬜ | ⬜ | — |
| 长字符串（1000+字符） | ⬜ | ⬜ | ⬜ | — |
| `UPROPERTY` + 说明符 | ⬜ | ⬜ | ⬜ | — |
| `TArray<T>` 元素 | ⬜ | ⬜ | ⬜ | — |
| `TMap<*, T>` 值 | ⬜ | ⬜ | ⬜ | — |
| `TMap<T, *>` 键 | ⬜ | ⬜ | 🚫 | FText 不能作为键 |
| `TSet<T>` 元素 | ⬜ | ⬜ | 🚫 | FText 不能作为集合元素 |

---

## 子矩阵 4：运算符 × FString

> 覆盖归属：`AngelscriptCoverageFStringExpressionTests.cpp`。

| 运算符 | 语法 | FString | FName | FText | 备注 |
|--------|------|:-------:|:-----:|:-----:|------|
| 赋值 | `=` | ⬜ | ⬜ | ⬜ | |
| 拼接 | `+` | ⬜ | 🚫 | 🚫 | 只有 FString |
| 拼接赋值 | `+=` | ⬜ | 🚫 | 🚫 | 只有 FString |
| 相等 | `==` | ⬜ | ⬜ | ⬜ | |
| 不等 | `!=` | ⬜ | ⬜ | ⬜ | |
| 比较 | `<, <=, >, >=` | ✅ | ✅ | 🚫 | FText 无比较 |
| 索引 | `[]` | ⬜ | 🚫 | 🚫 | 只有 FString |

---

## 子矩阵 5：FString 方法（重要）

> 覆盖归属：`AngelscriptCoverageFStringMethodTests.cpp`。

| 方法组 | 方法 | 状态 | 备注 |
|--------|------|:----:|------|
| **长度与判空** | `Len()`, `IsEmpty()` | ⬜ | 核心 |
| **拼接** | `Append()`, `AppendChar()`, `AppendInt()` | ⬜ | 修改字符串 |
| **插入** | `InsertAt()` | ⬜ | 插入字符/字符串 |
| **删除** | `RemoveAt()`, `RemoveSpacesInline()` | ⬜ | 修改字符串 |
| **查找** | `Find()`, `Contains()`, `StartsWith()`, `EndsWith()` | ⬜ | 搜索 |
| **分割** | `Split()`, `ParseIntoArray()` | ⬜ | 字符串→数组 |
| **替换** | `Replace()`, `ReplaceInline()` | ⬜ | 文本替换 |
| **大小写** | `ToLower()`, `ToUpper()` | ⬜ | 转换 |
| **裁剪** | `TrimStart()`, `TrimEnd()`, `TrimStartAndEnd()` | ⬜ | 去除空格 |
| **子串** | `Left()`, `Right()`, `Mid()` | ⬜ | 提取部分 |
| **反转** | `Reverse()` | ⬜ | 反转字符串 |
| **判断** | `IsNumeric()` | ⬜ | 谓词 |
| **格式化** | `Printf()` 静态方法 | ⬜ | 格式化 |
| **转换** | `ToInt()`, `ToFloat()` | ⬜ | String→数字 |
| **内存管理** | `Empty()`, `Reset()`, `Reserve()`, `Shrink()` | ⬜ | 容量管理 |

---

## 子矩阵 6：字面量

> 覆盖归属：`AngelscriptCoverageFStringExpressionTests.cpp`。

| 字面量形式 | 示例 | 状态 | 备注 |
|------|------|:---:|------|
| 基本字符串 | `"Hello"` | ⬜ | |
| 空字符串 | `""` | ⬜ | |
| 转义字符 | `"Hello\nWorld"` | ⬜ | \n, \t, \", \\, 等 |
| Unicode | `"你好"` | ⬜ | UTF-16 |
| 长字符串 | `"..."` (1000+ 字符) | ⬜ | |
| FName 字面量 | `n"MyName"` | ⬜ | 前缀 n |
| FText 字面量 | （通过构造函数） | ⬜ | FText::FromString |

---

## 子矩阵 7：类型转换

> 覆盖归属：`AngelscriptCoverageFStringExpressionTests.cpp`。

| 转换 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| FString → FName | `FName(str)` | ⬜ | 构造函数 |
| FName → FString | `name.ToString()` | ⬜ | 方法 |
| FString → FText | `FText::FromString(str)` | ⬜ | 静态方法 |
| FText → FString | `text.ToString()` | ⬜ | 方法 |
| FString → int | `str.ToInt()` | ⬜ | 解析 |
| FString → float | `str.ToFloat()` | ⬜ | 解析 |
| int → FString | `FString::Printf("%d", i)` | ⬜ | 格式化 |
| float → FString | `FString::Printf("%.2f", f)` | ⬜ | 格式化 |
| FString → bool | （无直接转换） | 🚫 | 需自定义 |

---

## 子矩阵 8：函数用法 × String 家族

> 覆盖归属：`AngelscriptCoverageFStringFunctionTests.cpp`。

| 函数用法 | 写法示例 | FString | FName | FText | 覆盖方法 |
|------|------|:---:|:---:|:---:|------|
| 参数（值传递） | `void F(FString X)` | ⬜ | ⬜ | ⬜ | — |
| 参数 `&in` | `void F(FString&in X)` | ⬜ | ⬜ | ⬜ | — |
| 参数 `&out` | `void F(FString&out X)` | ⬜ | ⬜ | ⬜ | — |
| 参数 `&inout` | `void F(FString&inout X)` | ⬜ | ⬜ | ⬜ | — |
| 返回值 | `FString F()` | ⬜ | ⬜ | ⬜ | — |
| 默认参数 | `void F(FString X = "default")` | ⬜ | ⬜ | ⬜ | — |
| 重载（按类型） | `F(FString)` vs `F(FName)` | ⬜ | ⬜ | ⬜ | — |
| UFUNCTION 参数/返回 | `UFUNCTION() FString F(FString)` | ⬜ | ⬜ | ⬜ | — |

---

## 子矩阵 9：容器 × String 家族

> 覆盖归属：`AngelscriptCoverageFStringPropertyTests.cpp`。

| 容器形态 | 状态 | 备注 |
|------|:---:|------|
| `TArray<FString>` | ⬜ | 字符串数组 |
| `TArray<FName>` | ⬜ | 名称数组 |
| `TArray<FText>` | ⬜ | 文本数组 |
| `TMap<FString, int>` | ⬜ | String 作键 |
| `TMap<int, FString>` | ⬜ | String 作值 |
| `TMap<FName, int>` | ⬜ | Name 作键 |
| `TSet<FString>` | ⬜ | String 集合 |
| `TSet<FName>` | ⬜ | Name 集合 |

---

## 子矩阵 10：String 特有场景

> 覆盖归属：各测试文件。

| 场景 | 示例 | 状态 | 测试文件 |
|------|------|:---:|---------|
| 空字符串处理 | `""`, `IsEmpty()` | ⬜ | Property/Expression |
| 特殊字符 | `"Hello\nWorld\t!"` | ⬜ | Expression |
| Unicode | `"你好世界"` | ⬜ | Expression |
| 长字符串（性能） | 1000+ 字符 | ⬜ | Property |
| 字符串拼接 | `s1 + s2 + s3` | ⬜ | Expression |
| 格式化 | `FString::Printf("%d", n)` | ⬜ | Method |
| 字符串分割 | `str.Split(",")` | ⬜ | Method |
| 字符串查找 | `str.Find("sub")` | ⬜ | Method |
| 大小写转换 | `str.ToLower()` | ⬜ | Method |
| 字符串比较 | `s1 == s2`, `s1 < s2` | ⬜ | Expression |
| FName 不可变性 | 赋值后内容不变 | ⬜ | Expression |
| FText 本地化 | （如果测试） | 🟡 | 可选 |

---

## FString vs FName vs FText 对比

| 特性 | FString | FName | FText |
|------|:-------:|:-----:|:-----:|
| 可变 | ✅ | 🚫 | 🚫 |
| 拼接 | ✅ (+) | 🚫 | 🚫 |
| 索引访问 | ✅ ([]) | 🚫 | 🚫 |
| 比较 | ✅ | ✅ | ✅ (==, !=) |
| 排序 | ✅ (<, >) | ✅ | 🚫 |
| TMap 键 | ✅ | ✅ | 🚫 |
| TSet 元素 | ✅ | ✅ | 🚫 |
| 本地化 | 🚫 | 🚫 | ✅ |
| 性能（查找） | 慢 | 快 | 中 |
| 性能（存储） | 高 | 低 | 中 |
| 用途 | 通用字符串 | 标识符/Tag | UI文本 |

---

## 待实现清单

### A. `AngelscriptCoverageFStringPropertyTests.cpp`（新建）
1. 3种String类型声明默认值读回（FString / FName / FText）
2. 写回环测试（C++ ↔ FProperty）
3. 特殊值测试（空字符串、长字符串、特殊字符）
4. 容器测试（TArray, TMap, TSet）
5. 说明符测试（选择 FString 作为代表性类型）

### B. `AngelscriptCoverageFStringExpressionTests.cpp`（新建）
1. 局部/全局声明（FString / FName / FText）
2. 运算符（赋值/拼接/比较/索引）
3. 字面量（基本/空/转义/Unicode）
4. 类型转换（String↔Name↔Text, String↔int/float）
5. 类成员（无 UPROPERTY）

### C. `AngelscriptCoverageFStringFunctionTests.cpp`（新建）
6. 函数参数（值/&in/&out/&inout）
7. 返回值
8. 默认参数
9. 重载（FString vs FName）
10. UFUNCTION 测试

### D. `AngelscriptCoverageFStringMethodTests.cpp`（新建）⭐
11. 长度与判空（Len, IsEmpty）
12. 拼接（Append, AppendChar, AppendInt）
13. 插入删除（InsertAt, RemoveAt）
14. 查找（Find, Contains, StartsWith, EndsWith）
15. 分割（Split, ParseIntoArray）
16. 替换（Replace, ReplaceInline）
17. 大小写（ToLower, ToUpper）
18. 裁剪（Trim*）
19. 子串（Left, Right, Mid）
20. 格式化（Printf）
21. 转换（ToInt, ToFloat）
22. 内存管理（Empty, Reserve, Shrink）

---

## String 特有注意事项

### 1. 字符编码
- ⚠️ FString 使用 UTF-16（TCHAR）
- ✅ 测试 Unicode 字符
- ✅ 测试特殊字符（换行、制表符、引号）

### 2. 性能考虑
- ⚠️ 频繁拼接应使用 StringBuilder 模式
- ✅ 测试长字符串性能
- ✅ Reserve 预分配测试

### 3. FName 特性
- ⚠️ FName 不可变
- ✅ 相同字符串的 FName 共享内存
- ✅ 适合作为标识符/Tag

### 4. FText 特性
- ⚠️ FText 用于本地化
- ⚠️ 不能作为 TMap 键或 TSet 元素
- ✅ ToString() 转换为 FString

### 5. 空字符串
- ✅ `""` vs `FString()` 行为相同
- ✅ `IsEmpty()` 判断
- ✅ `Len() == 0` 等价

---

## 测试运行指令

```powershell
# 运行所有 FString coverage 测试
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FString" -Label coverage-fstring -TimeoutMs 1200000

# 分组运行
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FStringProperty" -Label coverage-fstring-property -TimeoutMs 1200000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FStringExpression" -Label coverage-fstring-expression -TimeoutMs 1200000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FStringFunction" -Label coverage-fstring-function -TimeoutMs 1200000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FStringMethod" -Label coverage-fstring-method -TimeoutMs 1200000
```

---

## 预估工作量

| 任务 | 复杂度 | 估算时间 |
|------|:-----:|---------|
| FStringPropertyTests | 中等 | 2小时 |
| FStringExpressionTests | 中等 | 2小时 |
| FStringFunctionTests | 简单 | 1.5小时 |
| FStringMethodTests | 复杂 | 3小时 |
| 文档更新 | 简单 | 30分钟 |
| **总计** | | **约 9 小时** |

> 比 int/float 复杂，因为有大量方法需要测试。









