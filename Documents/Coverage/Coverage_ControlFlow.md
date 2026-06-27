# AngelScript 控制流和语法结构全覆盖矩阵

> 本文覆盖 AngelScript 中 **控制流语句和语法结构**的所有用法。
> 包括 if/for/while/switch、异常处理、命名空间等语言基础。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 条件语句 | `AngelscriptTest/Coverage/AngelscriptCoverageConditionalTests.cpp` | ✅ 已完成 |
| 循环语句 | `AngelscriptTest/Coverage/AngelscriptCoverageLoopTests.cpp` | ✅ 已完成 |
| 跳转语句 | `AngelscriptTest/Coverage/AngelscriptCoverageJumpTests.cpp` | ✅ 已完成 |
| 命名空间和作用域 | `AngelscriptTest/Coverage/AngelscriptCoverageNamespaceTests.cpp` | ✅ 已完成 |

✅ 所有控制流语法已覆盖

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：条件语句

### 1.1 if 语句

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 简单 if | `if (Condition) { ... }` | ✅ | |
| if-else | `if (C) { ... } else { ... }` | ✅ | |
| if-else if | `if (C1) { ... } else if (C2) { ... }` | ✅ | |
| if-else if-else | 完整链 | ✅ | |
| 嵌套 if | if 内部再 if | ✅ | |
| 单行 if（无大括号） | `if (C) Statement;` | ✅ | 不推荐 |

### 1.2 if 条件表达式

| 条件类型 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| bool 变量 | `if (bFlag)` | ⬜ | |
| 比较表达式 | `if (X > 10)` | ⬜ | |
| 逻辑与 | `if (A && B)` | ⬜ | 短路求值 |
| 逻辑或 | `if (A \|\| B)` | ⬜ | 短路求值 |
| 逻辑非 | `if (!Flag)` | ⬜ | |
| 复杂表达式 | `if ((A > 0) && (B < 10) \|\| C)` | ⬜ | |
| null 检查 | `if (Obj != nullptr)` | ⬜ | |
| IsValid 检查 | `if (IsValid(Obj))` | ⬜ | |
| 函数返回值 | `if (IsReady())` | ⬜ | |

### 1.3 三元运算符

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 基础三元 | `X = Condition ? A : B;` | ⬜ | |
| 嵌套三元 | `X = C1 ? A : (C2 ? B : C);` | ⬜ | 不推荐 |
| 返回值 | `return Flag ? 1 : 0;` | ⬜ | |

---

## 子矩阵 2：switch 语句

### 2.1 switch 基础

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 基础 switch | `switch (Value) { case A: ... }` | ✅ | |
| default 分支 | `switch (V) { ... default: ... }` | ✅ | |
| 多 case | `case 1: case 2: case 3: ...` | ✅ | 穿透 |
| break 语句 | `case 1: X; break;` | ✅ | 阻止穿透 |
| 穿透行为 | case 无 break | ✅ | Fall-through |

### 2.2 switch 类型

| switch 值类型 | 状态 | 说明 |
|--------------|------|------|
| int | ⬜ | 最常用 |
| int8/int16/int64 | ⬜ | 其他整型 |
| uint/uint8/... | ⬜ | 无符号 |
| 枚举 | ⬜ | 推荐用法 |
| FName | ⬜ | 字符串标识符 |
| FString | 🚫 | 不支持 |
| float/double | 🚫 | 不支持 |
| bool | ⬜ | 可以但不推荐 |

### 2.3 switch 枚举覆盖

| 场景 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| 枚举完整覆盖 | 所有枚举值都有 case | ⬜ | 编译器警告 |
| 缺少 default | 完整枚举可省略 default | ⬜ | |
| 新增枚举值 | 添加枚举值后 switch 警告 | ⬜ | 编译期检查 |

---

## 子矩阵 3：循环语句

### 3.1 for 循环

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 计数循环 | `for (int i = 0; i < N; i++)` | ✅ | |
| 递减循环 | `for (int i = N; i >= 0; i--)` | ✅ | |
| 步长循环 | `for (int i = 0; i < N; i += 2)` | ✅ | |
| 多变量初始化 | `for (int i = 0, j = 0; i < N; i++, j++)` | ✅ | |
| 无初始化 | `for (; i < N; i++)` | ✅ | |
| 无条件（无限循环） | `for (;;)` | ✅ | 需 break |
| 空 for | `for (int i = 0; i < N; i++);` | ✅ | 空循环体 |
| 嵌套 for | for 内部再 for | ✅ | |

### 3.2 for-each 循环

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 遍历数组（值） | `for (int Val : Arr)` | ⬜ | 拷贝 |
| 遍历数组（引用） | `for (int& Val : Arr)` | ⬜ | 可修改 |
| 遍历数组（const） | `for (const int& Val : Arr)` | ⬜ | 只读 |
| 遍历 Map | `for (auto& Pair : Map)` | ⬜ | Pair.Key/Value |
| 遍历 Set | `for (int Val : Set)` | ⬜ | |

### 3.3 while 循环

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 基础 while | `while (Condition) { ... }` | ✅ | |
| 无限循环 | `while (true) { ... }` | ✅ | 需 break |
| 嵌套 while | while 内部再 while | ✅ | |
| 空 while | `while (Condition);` | ✅ | 空循环体 |

### 3.4 do-while 循环

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 基础 do-while | `do { ... } while (Condition);` | ✅ | 至少执行一次 |
| 无限循环 | `do { ... } while (true);` | ✅ | |

---

## 子矩阵 4：跳转语句

### 4.1 break 语句

| 使用场景 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 退出 for | `for (...) { if (C) break; }` | ✅ | |
| 退出 while | `while (...) { if (C) break; }` | ✅ | |
| 退出 do-while | `do { if (C) break; } while (...)` | ✅ | |
| 退出 switch | `case 1: X; break;` | ✅ | |
| 嵌套循环 break | break 只退出内层 | ✅ | |

### 4.2 continue 语句

| 使用场景 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 跳过 for 迭代 | `for (...) { if (C) continue; }` | ✅ | |
| 跳过 while 迭代 | `while (...) { if (C) continue; }` | ✅ | |
| 跳过 do-while 迭代 | `do { if (C) continue; } while (...)` | ✅ | |
| 嵌套循环 continue | continue 只影响内层 | ✅ | |

### 4.3 return 语句

| 使用场景 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 无返回值 | `return;` | ⬜ | void 函数 |
| 返回值 | `return Value;` | ⬜ | |
| 返回表达式 | `return X + Y;` | ⬜ | |
| 返回三元 | `return C ? A : B;` | ⬜ | |
| 提前返回 | 函数中间 return | ⬜ | |
| 多个 return | 多个退出点 | ⬜ | |

### 4.4 goto 语句

| 支持 | 状态 | 说明 |
|------|------|------|
| goto | 🚫 | AS 不支持 goto |

---

## 子矩阵 5：异常处理

### 5.1 try-catch

| 支持 | 状态 | 说明 |
|------|------|------|
| try-catch | 🚫 | AS 不支持异常 |
| throw | 🚫 | 无异常机制 |

### 5.2 错误处理替代方案

| 方案 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 返回 bool | `bool Success = TryAction();` | ⬜ | |
| 返回错误码 | `int ErrorCode = DoAction();` | ⬜ | |
| 输出参数 | `void F(int&out ErrorCode)` | ⬜ | |
| ensure 断言 | `ensure(Condition)` | ⬜ | 调试时检查 |
| check 断言 | `check(Condition)` | ⬜ | 崩溃 |

---

## 子矩阵 6：命名空间

### 6.1 命名空间声明

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明命名空间 | `namespace MyNamespace { ... }` | ✅ | |
| 嵌套命名空间 | `namespace A { namespace B { ... } }` | ✅ | |
| 全局命名空间 | 顶层声明 | ✅ | 默认 |

### 6.2 命名空间使用

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 完全限定名 | `MyNamespace::MyFunction()` | ⬜ | |
| using 指令 | `using MyNamespace::MyFunction;` | ⬜ | |
| using namespace | `using namespace MyNamespace;` | ⬜ | 导入所有 |

### 6.3 命名空间内容

| 内容 | 状态 | 说明 |
|------|------|------|
| 函数 | ⬜ | 命名空间内声明函数 |
| 类 | ⬜ | 命名空间内声明类 |
| 枚举 | ⬜ | 命名空间内声明枚举 |
| 常量 | ⬜ | 命名空间内声明 const |
| 嵌套命名空间 | ✅ | 命名空间嵌套 |

---

## 子矩阵 7：作用域

### 7.1 变量作用域

| 作用域 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| 全局作用域 | 顶层声明 | ⬜ | |
| 命名空间作用域 | `namespace N { ... }` | ⬜ | |
| 类作用域 | `class C { ... }` | ⬜ | 成员变量 |
| 函数作用域 | `void F() { int X; }` | ⬜ | 局部变量 |
| 块作用域 | `{ int X; }` | ⬜ | 代码块 |
| for 循环作用域 | `for (int i = 0; ...)` | ⬜ | i 仅在循环内 |

### 7.2 变量遮蔽

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 局部遮蔽全局 | 局部变量同名 | ⬜ | 局部优先 |
| 内层遮蔽外层 | 嵌套块同名 | ⬜ | |
| 参数遮蔽成员 | 函数参数同名成员 | ⬜ | 用 this 区分 |

### 7.3 变量生命周期

| 生命周期 | 状态 | 说明 |
|---------|------|------|
| 进入作用域时构造 | ⬜ | 变量初始化 |
| 退出作用域时析构 | ⬜ | 自动清理 |
| 函数返回后销毁 | ⬜ | 局部变量 |
| 对象销毁后清理 | ⬜ | 成员变量 |

---

## 子矩阵 8：特殊控制流

### 8.1 短路求值

| 运算符 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| 逻辑与 && | `if (A && B)` | ⬜ | A false 则不计算 B |
| 逻辑或 \|\| | `if (A \|\| B)` | ⬜ | A true 则不计算 B |

### 8.2 逗号运算符

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 逗号表达式 | `X = (A, B, C);` | ⬜ | 返回最后一个值 |
| for 中使用 | `for (i=0, j=0; ...)` | ⬜ | |

---

## 子矩阵 9：预处理器

### 9.1 条件编译

| 指令 | 写法 | 状态 | 说明 |
|------|------|------|------|
| #if | `#if CONDITION` | ⬜ | |
| #elif | `#elif CONDITION` | ⬜ | |
| #else | `#else` | ⬜ | |
| #endif | `#endif` | ⬜ | |
| 平台宏 | `#if PLATFORM_WINDOWS` | ⬜ | |
| 配置宏 | `#if WITH_EDITOR` | ⬜ | |

### 9.2 包含文件

| 指令 | 写法 | 状态 | 说明 |
|------|------|------|------|
| #include | `#include "MyFile.as"` | ⬜ | |

---

## 子矩阵 10：注释

### 10.1 注释形式

| 形式 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 单行注释 | `// Comment` | ⬜ | |
| 多行注释 | `/* Comment */` | ⬜ | |
| 文档注释 | `/** Documentation */` | ⬜ | |

---

## 计划测试方法清单

### AngelscriptCoverageConditionalTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `IfBasic` | if / if-else / if-else if-else |
| `IfNested` | 嵌套 if |
| `IfConditions` | 各种条件表达式 |
| `TernaryOperator` | 三元运算符 |
| `SwitchBasic` | switch / case / default / break |
| `SwitchFallthrough` | case 穿透 |
| `SwitchEnum` | 枚举 switch |
| `SwitchTypes` | 各种类型 switch |

### AngelscriptCoverageLoopTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `ForBasic` | 基础 for 循环 |
| `ForVariations` | for 变体（递减/步长/无初始化） |
| `ForEach` | for-each 值/引用/const |
| `ForNested` | 嵌套 for |
| `WhileBasic` | while 循环 |
| `DoWhileBasic` | do-while 循环 |
| `InfiniteLoops` | 无限循环 + break |

### AngelscriptCoverageJumpTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `BreakInLoop` | break 退出循环 |
| `BreakInSwitch` | break 退出 switch |
| `ContinueInLoop` | continue 跳过迭代 |
| `ReturnEarly` | 提前 return |
| `MultipleReturns` | 多个返回点 |

### AngelscriptCoverageNamespaceTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `NamespaceDeclaration` | 命名空间声明 |
| `NamespaceNested` | 嵌套命名空间 |
| `NamespaceUsing` | using 指令 |
| `NamespaceQualifiedName` | 完全限定名 |
| `ScopeVariables` | 变量作用域 |
| `ScopeShadowing` | 变量遮蔽 |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **if 语句**（if/else/嵌套）
2. **switch 语句**（case/default/break/枚举）
3. **for 循环**（计数/for-each）

### 🟡 中优先级

4. **while 和 do-while**
5. **break 和 continue**
6. **return 语句**
7. **三元运算符**

### 🟢 低优先级

8. **命名空间**（声明/using）
9. **作用域和遮蔽**
10. **预处理器**（#if/#include）

---

## 已覆盖内容（来自其他测试）

以下控制流特性可能已在其他测试中隐式覆盖：

🟡 **for 循环**（在容器遍历测试中）
🟡 **if 语句**（在各种测试的断言中）
🟡 **return 语句**（在函数测试中）

**建议**：新测试应专注于：
- 边界情况（无限循环/嵌套）
- 语法变体（for 无初始化/do-while）
- 控制流组合（switch 内 for 内 if）

---

## 总结

控制流是 **编程语言的基础**：
- 条件判断 → if/switch
- 重复执行 → for/while
- 流程跳转 → break/continue/return
- 代码组织 → 命名空间/作用域

**估计工作量**：4 个测试文件，约 20-25 个测试方法
**优先级**：🔴🔴 高（语言基础）

**特殊说明**：
- 许多控制流特性已在其他测试中隐式使用
- 本测试套件应专注于**边界情况**和**语法变体**
- 与其他测试不同，这些是**语言层面**而非**UE 特性**





