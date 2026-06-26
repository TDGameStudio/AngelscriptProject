# int Coverage 审计报告 - 缺漏清单

> 生成时间：2026-06-27
> 对比基准：Coverage_IntProperty.md vs 实际测试代码

## 一、已完成覆盖总结 ✅

### AngelscriptCoverageIntPropertyTests.cpp
- ✅ **IntFamilyDeclarationDefaults** - 8种整型 UPROPERTY 声明默认值
- ✅ **IntFamilyWriteRoundTrip** - 8种整型写回环测试
- ✅ **IntFamilyBoundaryValues** - 所有宽度的边界值（min/max）
- ✅ **IntContainerProperties** - 部分容器测试（TArray<int/int64/uint8>, TMap<int,int>, TMap<int,FString>）
- ✅ **IntPropertySpecifierFlags** - **完整的**说明符覆盖（17个说明符 + meta + 组合）

### AngelscriptCoverageIntExpressionTests.cpp
- ✅ **LocalDeclarations** - 局部声明（默认初始化、延迟初始化、const、auto）
- ✅ **GlobalConstDeclarations** - 8种整型全局 const
- ✅ **ArithmeticOperators** - 算术运算符（+ - * / % 和一元负）
- ✅ **BitwiseAndShiftOperators** - 位运算和移位（& | ^ ~ << >>）
- ✅ **ComparisonOperators** - 比较运算符（== != < <= > >=）
- ✅ **CompoundAssignmentOperators** - 复合赋值和自增减（+= -= *= /= %= &= |= ^= <<= >>= ++ --）
- ✅ **IntegerLiterals** - 字面量（十进制、十六进制、二进制、八进制、int64提升、uint范围）
- ✅ **IntegerConversions** - 类型转换（宽化、截断、有符号↔无符号、int↔double、int→int8）

---

## 二、待补充缺漏（按优先级排序）

### 🔴 优先级 P0 - 核心缺漏

#### 1. **函数用法 - 整个子矩阵 6 缺失**
**需要新建：** `AngelscriptCoverageIntFunctionTests.cpp`

| 缺漏项 | 覆盖范围 |
|------|---------|
| 参数值传递 | `void F(int X)` - 全部8种宽度 |
| 参数 `&in` | `void F(int&in X)` - 全部8种宽度 |
| 参数 `&out` | `void F(int&out X)` - 全部8种宽度 |
| 参数 `&inout` | `void F(int&inout X)` - 全部8种宽度 |
| 返回值 | `int F()` - 全部8种宽度 |
| 默认参数 | `void F(int X = 3)` - 代表性宽度 |
| 多返回值 | `void F(int&out A, int&out B)` - 代表性宽度 |
| 函数重载 | `F(int)` vs `F(int64)` vs `F(uint)` |
| UFUNCTION 参数/返回 | `UFUNCTION() int F(int)` - 代表性宽度 |

**测试模式：**
- Pattern B: 全局函数通过 `FASGlobalFunctionInvoker`
- Pattern C: UFUNCTION 通过 `FFunctionInvoker`（需要 Actor 上下文）

---

#### 2. **容器补全 - 子矩阵 5 部分缺失**

在 `IntContainerProperties` 中补充：

| 缺漏项 | 备注 |
|------|------|
| `TArray<int8>` | 补充剩余宽度 |
| `TArray<int16>` | 补充剩余宽度 |
| `TArray<uint16>` | 补充剩余宽度 |
| `TArray<uint>` | 补充剩余宽度 |
| `TArray<uint64>` | 补充剩余宽度 |
| `TMap<FString, int>` | int 作值（字符串键） |
| `TSet<int>` | 通过 `GetSetNumByPath` / `SetContainsByPath` |

---

### 🟡 优先级 P1 - 运算符和类型转换补全

#### 3. **移位运算符 >>> - 子矩阵 7 部分缺失**

在 `BitwiseAndShiftOperators` 中补充：
- 算术右移 `>>>` 运算符测试

```cpp
int OpArithmeticShiftRight()
{
    int x = -256;  // 负数算术右移保持符号位
    return x >>> 2;
}
```

---

#### 4. **类型转换 - 子矩阵 9 部分缺失**

在 `IntegerConversions` 中补充：

| 缺漏项 | 示例 |
|------|------|
| int ↔ enum | `int(EMyEnum::Value)` / `EMyEnum(5)` |
| 反向窄化 | `int64(int8Val)` 等其它组合 |

---

### 🟢 优先级 P2 - 扩展和边界用例

#### 5. **声明上下文 - 子矩阵 2 部分缺失**

| 缺漏项 | 备注 |
|------|------|
| 局部变量其他宽度 | 目前只有 `int`，补充 int8/int16/int64/uint8/uint16/uint/uint64 |
| 类成员（无 UPROPERTY） | 需要测试脚本可见但非 UPROPERTY 的成员 |

---

#### 6. **字面量补全 - 子矩阵 8 待确认**

| 缺漏项 | 备注 |
|------|------|
| 数字分隔符 | 确认 AS 是否支持 `1_000_000` 语法 |

---

#### 7. **UPROPERTY 说明符扩展到其他宽度 - 子矩阵 4**

| 缺漏项 | 备注 |
|------|------|
| int8/int16/int64/uint8/uint16/uint/uint64 | 目前只在 `int`(int32) 上测试了全部说明符，其他宽度可各挂代表性说明符（如 EditAnywhere + meta ClampMin/Max） |

**注：** 此项优先级较低，因为说明符行为是类型无关的（`FProperty` 层面统一处理）。

---

### ⚫ 优先级 P3 - 高级特性（暂缓）

#### 8. **网络复制 - 子矩阵 3**
- `Replicated` / `ReplicatedUsing`
- **原因：** Haze fork 中这些不是合法的属性说明符，需要单独的 Networking PIE 套件

#### 9. **USTRUCT 嵌套 - 子矩阵 3**
- USTRUCT 内 int 成员的嵌套路径读写
- **原因：** 需要先有 USTRUCT 覆盖测试框架

#### 10. **嵌套容器 - 子矩阵 5**
- `TArray<TArray<int>>`
- **原因：** 路径解析器当前有限制

---

## 三、实施计划

### 第一批（核心补全）- 立即执行
1. ✅ 审计报告（本文档）
2. 🟡 补充 `IntContainerProperties` - 添加 TSet<int> + TMap<FString,int> + 剩余 TArray 宽度
3. 🟡 补充 `BitwiseAndShiftOperators` - 添加 `>>>` 运算符
4. 🟡 新建 `AngelscriptCoverageIntFunctionTests.cpp` - 完整子矩阵 6
5. 🟡 补充 `IntegerConversions` - 添加 enum 转换

### 第二批（扩展补全）- 后续执行
6. 补充 `LocalDeclarations` - 其他宽度
7. 探索数字分隔符语法
8. 扩展说明符到其他宽度（可选）

### 第三批（高级特性）- 独立规划
9. Networking 套件（Replicated 等）
10. USTRUCT 嵌套测试
11. 嵌套容器支持

---

## 四、矩阵更新清单

需要在 `Coverage_IntProperty.md` 中更新的状态标记：

### 子矩阵 4 - UPROPERTY 说明符
- ⬜ → ✅ 的行（已在 IntPropertySpecifierFlags 中实现）：
  - EditDefaultsOnly
  - EditInstanceOnly
  - VisibleAnywhere
  - VisibleDefaultsOnly
  - VisibleInstanceOnly
  - BlueprintReadWrite
  - BlueprintHidden
  - AdvancedDisplay
  - Interp
  - ExposeOnSpawn
  - meta=(UIMin/UIMax)
  - 组合说明符行

---

## 五、估算工作量

| 任务 | 复杂度 | 估算时间 |
|------|:-----:|---------|
| 补充容器测试 | 简单 | 30分钟 |
| 补充 >>> 运算符 | 简单 | 10分钟 |
| 新建 Function 测试文件 | 中等 | 2小时 |
| 补充 enum 转换 | 简单 | 30分钟 |
| 更新矩阵文档状态 | 简单 | 20分钟 |
| **总计** | | **约 4 小时** |

---

## 六、测试运行指令

```powershell
# 运行所有 int coverage 测试
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Int" -Label coverage-int -TimeoutMs 1200000

# 分组运行
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.IntProperty" -Label coverage-int-property -TimeoutMs 1200000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.IntExpression" -Label coverage-int-expression -TimeoutMs 1200000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.IntFunction" -Label coverage-int-function -TimeoutMs 1200000
```
