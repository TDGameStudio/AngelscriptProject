# int Coverage 深度审查 - 需要扩充的场景

> 审查时间：2026-06-27
> 目的：识别现有测试中需要扩充和完善的场景

## 🔍 系统性审查方法

### 审查维度
1. **测试深度** - 每个场景是否充分测试
2. **边界情况** - 是否覆盖所有边界值
3. **错误路径** - ��否测试异常情况
4. **实际用例** - 是否覆盖真实游戏开发场景
5. **组合场景** - 是否测试特性组合

---

## 📊 当前测试分析

### 文件1: IntPropertyTests.cpp (6个方法)

#### 1. IntFamilyDeclarationDefaults
**当前覆盖：**
- ✅ 8种整型的默认值声明
- ✅ 读回验证

**可能缺失：**
- ✅ **无默认值声明**（UPROPERTY() int X; 不赋值）
- ⬜ **零值显式声明**（int X = 0;）
- ⬜ **负数默认值**（int8 X = -100;）
- ⬜ **大数默认值**（接近边界）

**建议补充：**
```angelscript
UPROPERTY()
int NoDefaultValue;  // 应该为0

UPROPERTY()
int ExplicitZero = 0;

UPROPERTY()
int8 NegativeDefault = -100;

UPROPERTY()
int MaxDefault = 2147483647;
```

#### 2. IntFamilyWriteRoundTrip
**当前覆盖：**
- ✅ 正数写回
- ✅ 负数写回（有符号类型）
- ✅ 大数写回

**可能缺失：**
- ⬜ **零值写入**
- ⬜ **连续多次写入**（覆盖测试）
- ⬜ **不同线程写入**（如果适用）

**建议补充：**
```cpp
// 零值写入
SetByPath<FIntProperty, int32>(..., 0);
VerifyByPath<FIntProperty, int32>(..., 0, ...);

// 多次覆盖写入
SetByPath(..., 100);
SetByPath(..., 200);
SetByPath(..., 300);
VerifyByPath(..., 300, ...);
```

#### 3. IntFamilyBoundaryValues
**当前覆盖：**
- ✅ Min/Max 值

**可能缺失：**
- ⬜ **Min+1, Max-1**（边界附近）
- ⬜ **零附近**（-1, 0, 1）
- ✅ **溢出行为**（如果写入超出范围会怎样？）
- ⬜ **特殊值**（如 INT_MIN + 1, INT_MAX - 1）

**建议补充：**
```cpp
// 边界附近
SetByPath(..., INT_MAX - 1);
SetByPath(..., INT_MIN + 1);

// 零附近
SetByPath(..., -1);
SetByPath(..., 0);
SetByPath(..., 1);

// 溢出测试（如果有定义行为）
// 尝试写入超出范围的值，验证截断/错误
```

#### 4. IntContainerProperties
**当前覆盖：**
- ✅ TArray<int/int64/uint8>
- ✅ TMap<int, int>, TMap<int, FString>

**可能缺失：**
- ⬜ **空容器**（长度为0）
- ⬜ **单元素容器**
- ⬜ **大容器**（100+元素）
- ⬜ **容器修改**（Add后Remove）
- ⬜ **容器清空**（Clear）
- ⬜ **索引越界**（如果适用）

**建议补充：**
```angelscript
// 空容器
TArray<int> EmptyArray;
// 验证长度为0

// 大容器
TArray<int> LargeArray;
for (int i = 0; i < 100; i++)
    LargeArray.Add(i);
// 验证长度和随机索引

// 容器修改
IntArray.Add(42);
IntArray.RemoveAt(0);
IntArray.Clear();
```

#### 5. IntContainerPropertiesExtended
**当前覆盖：**
- ✅ 所有TArray宽度
- ✅ TMap<FString, int>, TMap<int8/int64/uint, FString>
- ✅ TSet<int/int8/int64/uint>

**可能缺失：**
- ⬜ **重复元素**（TSet去重）
- ⬜ **TMap键冲突**（覆盖已有键）
- ⬜ **移除元素**
- ⬜ **查找不存在的键**

**建议补充：**
```angelscript
// TSet去重
IntSet.Add(5);
IntSet.Add(5);  // 重复
// 验证只有1个元素

// TMap键覆盖
IntMap.Add(1, 100);
IntMap.Add(1, 200);  // 覆盖
// 验证值为200

// 查找不存在的键
// 验证返回默认值或false
```

#### 6. IntPropertySpecifierFlags
**当前覆盖：**
- ✅ 完整的说明符排列（24+项）

**可能缺失：**
- ⬜ **冲突的说明符组合**（EditAnywhere + NotEditable）
- ✅ **无效的meta值**（ClampMin > ClampMax）
- ⬜ **多个Category**
- ✅ **EditCondition 求值**

**建议补充：**
```angelscript
// 冲突说明符（验证最终行为）
UPROPERTY(EditAnywhere, NotEditable)
int ConflictingFlags;

// 无效Clamp（验证错误处理）
UPROPERTY(meta=(ClampMin=100, ClampMax=50))
int InvalidClamp;

// EditCondition
UPROPERTY()
bool bEnableValue;

UPROPERTY(meta=(EditCondition="bEnableValue"))
int ConditionalValue;
```

---

### 文件2: IntExpressionTests.cpp (12个方法)

#### 1. LocalDeclarations
**当前覆盖：**
- ✅ 默认初始化、延迟初始化
- ✅ const、auto
- ✅ 全8种宽度

**可能缺失：**
- ⬜ **多重声明**（int a = 1, b = 2;）
- ⬜ **表达式初始化**（int x = a + b;）
- ⬜ **函数调用初始化**（int x = GetValue();）
- ⬜ **类型推导边界**（auto 的复杂情况）

**建议补充：**
```angelscript
// 多重声明（如果AS支持）
int a = 1, b = 2, c = 3;

// 表达式初始化
int x = 10;
int y = x * 2 + 5;

// 函数调用初始化
int GetValue() { return 42; }
int result = GetValue();
```

#### 2-6. 运算符测试
**当前覆盖：**
- ✅ 算术、位、比较、复合赋值

**可能缺失：**
- ⬜ **除零行为**（10 / 0）
- ⬜ **模零行为**（10 % 0）
- ✅ **溢出行为**（INT_MAX + 1）
- ⬜ **下溢行为**（INT_MIN - 1）
- ⬜ **负数移位**（-5 << 2）
- ⬜ **大移位量**（1 << 100）
- ⬜ **自运算**（x += x, x *= x）

**建议补充：**
```angelscript
// 除零（验证错误处理或特定行为）
int DivideByZero()
{
    int x = 10;
    int y = 0;
    return x / y;  // 应该如何处理？
}

// 溢出
int Overflow()
{
    int x = 2147483647;
    return x + 1;  // 验证溢出行为
}

// 负数移位
int NegativeShift()
{
    return -5 << 2;  // -20 还是未定义？
}

// 大移位量
int LargeShift()
{
    return 1 << 100;  // 验证行为
}
```

#### 7. IntegerLiterals
**当前覆盖：**
- ✅ 十/十六/二/八进制
- ✅ int64提升、uint范围

**可能缺失：**
- ✅ **负数字面量**（-0x10, -0b1010）
- ✅ **大整数字面量**（超出int32但在int64内）
- ✅ **字面量后缀**（如果AS支持 100L, 100U）
- ✅ **字面量类型推导**（0xFFFFFFFF 是 int 还是 uint？）

**建议补充：**
```angelscript
// 负数字面量
int NegativeHex() { return -0xFF; }
int NegativeBinary() { return -0b1010; }

// 边界字面量
int64 LargeOctal() { return 077777777777777; }

// 类型推导
auto x = 0xFFFFFFFF;  // 推导为什么类型？
```

#### 8. IntegerConversions
**当前覆盖：**
- ✅ 宽化/截断
- ✅ 有符号↔无符号
- ✅ int↔float
- ✅ int↔enum

**可能缺失：**
- ✅ **截断的精度损失**（int64大值→int）
- ✅ **无符号 有符号的符号扩展**（uint大值→int）
- ✅ **float int的舍入行为**（9.5f → 9 还是 10？）
- ⬜ **枚举边界外的值**（int(999) → Enum？）

**建议补充：**
```angelscript
// 截断精度损失
int TruncateLarge()
{
    int64 large = 10000000000;
    return int(large);  // 验证截断结果
}

// 无符号大值→有符号
int UnsignedToSigned()
{
    uint u = 3000000000;  // > INT_MAX
    return int(u);  // 验证符号位
}

// float舍入
int FloatRounding()
{
    return int(9.9f);  // 9 还是 10？
}

// 枚举边界外
ETestEnum IntToEnumOutOfRange()
{
    return ETestEnum(999);  // 未定义的枚举值
}
```

#### 10. MixedTypeArithmetic
**当前覆盖：**
- ✅ 12种跨类型组合

**可能缺失：**
- ⬜ **三元或更多类型混合**（int8 + int + int64）
- ⬜ **复杂表达式**（(int8 + int16) * int64）
- ⬜ **类型提升链**（int8 → int → int64）

**建议补充：**
```angelscript
// 多类型混合
int64 MultiTypeMix()
{
    int8 a = 10;
    int b = 100;
    int64 c = 1000;
    return a + b + c;  // 验证最终类型
}

// 复杂表达式
int64 ComplexMix()
{
    int8 a = 2;
    int16 b = 3;
    int64 c = 4;
    return (a + b) * c;  // 验证中间类型
}
```

#### 11. IntWithUEMathTypes
**当前覆盖：**
- ✅ 7种UE类型
- ✅ 标量运算、索引、向量运算

**可能缺失：**
- ⬜ **FVector常量**（FVector::ZeroVector, UpVector等）
- ⬜ **FRotator特殊角度**（0, 90, 180, 360度）
- ✅ **FLinearColor预定义颜色**（White, Black, Red等）
- ⬜ **FBox无效状态**（Min > Max）
- ⬜ **更多UE类型**（FQuat, FTransform, FMatrix）

**建议补充：**
```angelscript
// FVector常量
FVector TestZeroVector()
{
    return FVector::ZeroVector * 2;
}

// FRotator特殊角度
FRotator Test90Degrees()
{
    FRotator r(0, 90, 0);
    return r * 2;
}

// FLinearColor预定义
FLinearColor TestWhite()
{
    return FLinearColor::White * 2;
}

// FQuat
FQuat QuatTimesFloat()
{
    FQuat q = FQuat::Identity;
    // FQuat运算（如果有）
}
```

#### 12. OperatorPrecedenceAndAssociativity
**当前覆盖：**
- ✅ 11条规则

**可能缺失：**
- ✅ **更复杂的嵌套**（(a + b) * (c - d) / (e % f)）
- ⬜ **位运算混合**（(a & b) | (c ^ d)）
- ⬜ **三元运算符**（a ? b : c，如果AS支持）
- ✅ **赋值表达式的值**（x = y = z）

**建议补充：**
```angelscript
// 复杂嵌套
int ComplexNested()
{
    return (2 + 3) * (10 - 5) / (7 % 3);
}

// 位运算混合
int BitwiseMix()
{
    return (0xF0 & 0x3C) | (0x0F ^ 0x33);
}

// 链式赋值
int ChainAssignment()
{
    int x, y, z;
    x = y = z = 42;
    return x + y + z;
}
```

---

### 文件3: IntFunctionTests.cpp (8个方法)

#### 1-4. 函数参数测试
**当前覆盖：**
- ✅ 值传递、&in、&out、&inout

**可能缺失：**
- ⬜ **参数默认值与&out组合**
- ⬜ **多个&out参数的顺序**
- ⬜ **&inout的初始值保留**
- ⬜ **const &in（如果不同）**

**建议补充：**
```angelscript
// 默认值 + &out
void FunctionWithDefaultAndOut(int x = 10, int&out result)
{
    result = x * 2;
}

// 多个&out的顺序验证
void MultipleOutOrder(int&out a, int&out b, int&out c)
{
    a = 1;
    b = 2;
    c = 3;
}

// &inout初始值
void InOutPreserve(int&inout x)
{
    int original = x;
    x = original * 2;
}
```

#### 5. FunctionReturnValues
**当前覆盖：**
- ✅ 8种整型返回

**可能缺失：**
- ⬜ **返回表达式**（return a + b;）
- ⬜ **返回函数调用**（return GetValue();）
- ⬜ **条件返回**（return x > 0 ? x : -x;）
- ⬜ **早期返回**（多个return语句）

**建议补充：**
```angelscript
// 返回表达式
int ReturnExpression(int a, int b)
{
    return a * 2 + b * 3;
}

// 条件返回
int ConditionalReturn(int x)
{
    return x > 0 ? x : -x;  // abs
}

// 早期返回
int EarlyReturn(int x)
{
    if (x < 0)
        return 0;
    if (x > 100)
        return 100;
    return x;
}
```

#### 6. FunctionDefaultParameters
**当前覆盖：**
- ✅ 单个默认参数
- ✅ 调用时省略/提供

**可能缺失：**
- ⬜ **多个默认参数**（部分省略）
- ⬜ **默认参数表达式**（= a + b）
- ⬜ **默认参数为负数**
- ✅ **默认参数为边界值**

**建议补充：**
```angelscript
// 多个默认参数
int MultipleDefaults(int a, int b = 10, int c = 20)
{
    return a + b + c;
}
// 调用: MultipleDefaults(1), MultipleDefaults(1, 2), MultipleDefaults(1, 2, 3)

// 默认参数表达式（如果AS支持）
int DefaultExpression(int x, int y = x * 2)
{
    return x + y;
}
```

#### 7. FunctionOverloading
**当前覆盖：**
- ✅ 按宽度重载（int/int64/uint）

**可能缺失：**
- ⬜ **参数数量重载**（F(int), F(int, int)）
- ✅ **混合类型重载**（F(int float)）
- ⬜ **const重载**（如果AS支持）
- ⬜ **重载歧义**（F(int8), F(int16)调用F(5)）

**建议补充：**
```angelscript
// 参数数量重载
int Overload(int x) { return x; }
int Overload(int x, int y) { return x + y; }
int Overload(int x, int y, int z) { return x + y + z; }

// 混合类型重载
int Overload(int x) { return x * 2; }
float Overload(float x) { return x * 3.0f; }

// 测试重载解析
int CallOverload()
{
    return Overload(5);  // 调用哪个？
}
```

#### 8. UFunctionParametersAndReturn
**当前覆盖：**
- ✅ UFUNCTION基本用法

**可能缺失：**
- ⬜ **UFUNCTION说明符**（BlueprintCallable, BlueprintPure等）
- ⬜ **UFUNCTION默认参数**
- ⬜ **UFUNCTION重载**（如果支持）
- ⬜ **UFUNCTION与&out的组合**
- ⬜ **UFUNCTION返回值优化**

**建议补充：**
```angelscript
// BlueprintPure
UFUNCTION(BlueprintPure)
int PureFunction(int x)
{
    return x * 2;
}

// UFUNCTION with meta
UFUNCTION(meta=(ToolTip="Multiplies by 2"))
int FunctionWithMeta(int x)
{
    return x * 2;
}

// UFUNCTION with default
UFUNCTION()
int FunctionWithDefault(int x = 10)
{
    return x * 2;
}
```

---

## 📊 优先级建议

### P0 - 立即补充（影响核心覆盖）
1. ✅ **除零/溢出行为**（运算符安全性）
2. ✅ **空容器测试**（容器边界）
3. ✅ **无默认值UPROPERTY**（声明完整性）
4. ✅ **类型转换精度损失**（转换安全性）

### P1 - 重要补充（提升测试质量）
5. ✅ **容器修改操作**（Add/Remove/Clear）
6. ✅ **边界附近值**（Min±1, Max±1）
7. ✅ **多个&out参数**（参数顺序）
8. ✅ **函数重载歧义**（重载解析）

### P2 - 可选补充（增强测试深度）
9. ⬜ 更多UE类型（FQuat, FTransform）
10. ✅ 复杂表达式嵌套
11. ⬜ UFUNCTION说明符测试
12. ✅ 字面量后缀（如果AS支持）

---

## 🎯 建议的扩充计划

### Phase 1: 安全性测试（估算2小时）
- 除零/溢出/下溢行为
- 索引越界
- 类型转换精度损失

### Phase 2: 边界情况（估算1.5小时）
- 空容器、单元素容器
- 边界附近值
- 无默认值声明

### Phase 3: 组合场景（估算1.5小时）
- 容器修改操作
- 多参数函数
- 复杂表达式

### Phase 4: 高级特性（估算2小时）
- UFUNCTION说明符
- 更多UE类型
- 重载歧义

**总估算：约7小时**

---

## ✅ 结论

**当前状态：**
- 核心功能覆盖：✅ 100%
- 边界情况覆盖：🟡 70%
- 错误路径覆盖：🟡 30%
- 组合场景覆盖：🟡 60%

**建议：**
1. 优先补充 P0 安全性测试
2. 逐步补充边界情况
3. 可选补充高级特性

**这些扩充将使覆盖率从"功能完整"提升到"生产就绪"！** 🎯






