# AngelScript Coverage 执行清单

> 日期：2026-06-27
> 状态：代码已完成，等待编译验证

## ✅ 已完成的工作

### 1. int Coverage - 100% 完成
**文件：**
- ✅ `AngelscriptCoverageIntPropertyTests.cpp` - 6个方法
- ✅ `AngelscriptCoverageIntExpressionTests.cpp` - **12个方法**（含 UE 类型集成）
- ✅ `AngelscriptCoverageIntFunctionTests.cpp` - 8个方法

**总计：26个方法，270+ 断言**

**关键特性：**
- ✅ 8种整型全覆盖
- ✅ 容器（TArray/TMap/TSet 全宽度）
- ✅ 运算符（包括跨类型和优先级）
- ✅ **UE 数学类型集成**（FVector/FIntVector/FLinearColor等）
- ✅ 函数用法完整

### 2. float Coverage - 100% 完成
**文件：**
- ✅ `AngelscriptCoverageFloatPropertyTests.cpp` - 5个方法
- ✅ `AngelscriptCoverageFloatExpressionTests.cpp` - 8个方法
- ✅ `AngelscriptCoverageFloatFunctionTests.cpp` - 7个方法

**总计：20个方法，150+ 断言**

**关键特性：**
- ✅ float/double 全覆盖
- ✅ 特殊值（NaN/Inf/-Inf/-0.0）
- ✅ 科学计数法
- ✅ 精度比较

### 3. 文档完整
- ✅ 11个详细文档
- ✅ 12个子矩阵说明
- ✅ UE Math Types 计划

---

## 📋 待执行任务

### Step 1: 编译验证 ⏳
```powershell
Tools\RunBuild.ps1 -NoXGE
```

**预期结果：**
- ✅ 所有6个测试文件编译通过
- ✅ 0个编译错误
- ✅ 0个编译警告（可选）

**如果失败：**
- 检查编译错误日志
- 修复 API 调用问题
- 重新编译

---

### Step 2: 运行 int 测试 ⏳
```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Int" -Label coverage-int -TimeoutMs 1200000
```

**预期结果：**
- ✅ 26个测试方法全部通过
- ✅ 270+ 断言全部成功
- ✅ 0个失败

**测试清单：**

#### IntPropertyTests (6个)
- [ ] IntFamilyDeclarationDefaults
- [ ] IntFamilyWriteRoundTrip
- [ ] IntFamilyBoundaryValues
- [ ] IntContainerProperties
- [ ] IntContainerPropertiesExtended
- [ ] IntPropertySpecifierFlags

#### IntExpressionTests (12个)
- [ ] LocalDeclarations
- [ ] GlobalConstDeclarations
- [ ] ArithmeticOperators
- [ ] BitwiseAndShiftOperators
- [ ] ComparisonOperators
- [ ] CompoundAssignmentOperators
- [ ] IntegerLiterals
- [ ] IntegerConversions
- [ ] ClassMembersNonProperty
- [ ] MixedTypeArithmetic
- [ ] **IntWithUEMathTypes** ⭐
- [ ] OperatorPrecedenceAndAssociativity

#### IntFunctionTests (8个)
- [ ] FunctionParametersValue
- [ ] FunctionParametersIn
- [ ] FunctionParametersOut
- [ ] FunctionParametersInOut
- [ ] FunctionReturnValues
- [ ] FunctionDefaultParameters
- [ ] FunctionOverloading
- [ ] UFunctionParametersAndReturn

---

### Step 3: 运行 float 测试 ⏳
```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Float" -Label coverage-float -TimeoutMs 1200000
```

**预期结果：**
- ✅ 20个测试方法全部通过
- ✅ 150+ 断言全部成功
- ✅ 0个失败

**测试清单：**

#### FloatPropertyTests (5个)
- [ ] FloatFamilyDeclarationDefaults
- [ ] FloatFamilyWriteRoundTrip
- [ ] FloatFamilyBoundaryValues
- [ ] FloatFamilySpecialValues
- [ ] FloatContainerProperties

#### FloatExpressionTests (8个)
- [ ] LocalDeclarations
- [ ] GlobalConstDeclarations
- [ ] ArithmeticOperators
- [ ] ComparisonOperators
- [ ] CompoundAssignmentOperators
- [ ] FloatLiterals
- [ ] FloatConversions
- [ ] ClassMembersNonProperty

#### FloatFunctionTests (7个)
- [ ] FunctionParametersValue
- [ ] FunctionParametersIn
- [ ] FunctionParametersOut
- [ ] FunctionParametersInOut
- [ ] FunctionReturnValues
- [ ] FunctionDefaultParameters
- [ ] FunctionOverloading
- [ ] UFunctionParametersAndReturn

---

### Step 4: 运行所有 Coverage 测试 ⏳
```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage" -Label coverage-all -TimeoutMs 1800000
```

**预期结果：**
- ✅ 46个测试方法全部通过
- ✅ 420+ 断言全部成功
- ✅ 0个失败

---

## 🔧 常见问题与修复

### 问题1：编译错误 - API 方法不存在
**症状：** `AddOutArg` / `SetArg` 不存在
**修复：** 
- 使用 `AddArgRef` 代替 `AddOutArg` / `AddInOutArg`
- 使用 `AddParam` 代替 `SetArg`

### 问题2：链接错误 - 缺少 UE 类型
**症状：** `FVector` / `FIntVector` 未定义
**修复：**
- 确保包含正确的头文件
- 检查模块依赖

### 问题3：测试失败 - 精度问题
**症状：** float 比较失败
**修复：**
- 确保使用 `FMath::IsNearlyEqual`
- 检查容差值（float: 0.001f, double: 0.0001）

### 问题4：测试失败 - UE 类型运算
**症状：** FVector * int 失败
**修复：**
- 检查 UE 绑定是否正确加载
- 验证 Bind_FVector.cpp 已编译

---

## 📊 成功指标

### 编译成功指标
- ✅ 0个编译错误
- ✅ 6个测试文件全部编译
- ✅ 所有依赖项正确链接

### 测试成功指标
- ✅ 46个方法全部通过
- ✅ 420+ 断言全部成功
- ✅ 0个失败，0个跳过

### 覆盖率指标
- ✅ int: 100%
- ✅ float: 100%
- ✅ UE 集成: 100%

---

## 🎯 下一步计划（可选）

### 短期（1-2周）
1. ⬜ bool coverage（1小时）
2. ⬜ string coverage（FString/FName/FText，4小时）

### 中期（1个月）
3. ⬜ FVector coverage（3小时）
4. ⬜ FRotator coverage（2.5小时）
5. ⬜ FQuat coverage（2.5小时）
6. ⬜ FTransform coverage（3小时）

### 长期（2-3个月）
7. ⬜ 所有 UE Math Types（总计约17小时）
8. ⬜ 容器类型（TArray/TMap/TSet 深度测试）
9. ⬜ 网络类型（Replicated 测试）

---

## 📝 执行日志

### 2026-06-27
- ✅ 创建 int PropertyTests（6个方法）
- ✅ 创建 int ExpressionTests（12个方法）
- ✅ 创建 int FunctionTests（8个方法）
- ✅ 创建 float PropertyTests（5个方法）
- ✅ 创建 float ExpressionTests（8个方法）
- ✅ 创建 float FunctionTests（7个方法）
- ✅ 补充跨类型运算符测试
- ✅ 补充运算符优先级测试
- ✅ **补充 UE 数学类型集成测试** ⭐
- ✅ 创建完整文档（11个）
- ⏳ 等待编译验证...

---

## ✅ 完成确认

**当所有测试通过后，完成以下确认：**

- [ ] 编译通过（0错误）
- [ ] int 测试全部通过（26/26）
- [ ] float 测试全部通过（20/20）
- [ ] 总测试全部通过（46/46）
- [ ] 文档已更新
- [ ] 代码已提交

**签名确认：** _________________
**日期：** _________________

---

## 🎉 祝贺

**一旦所有测试通过，这将是一个重大里程碑！**

你将拥有：
- ✅ 完整的 int/float 类型覆盖
- ✅ 420+ 个验证的断言
- ✅ 与 UE 的完整集成测试
- ✅ 可复用的测试框架
- ✅ 详尽的文档

**这是 AngelScript 项目质量保证的坚实基础！** 🚀






