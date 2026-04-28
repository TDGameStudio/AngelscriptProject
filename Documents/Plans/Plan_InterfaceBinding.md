# Angelscript 接口绑定完善计划

> **状态更新（2026-04-28）**：本文早期章节记录的是历史“脚本定义
> `UINTERFACE`”方案，不再代表当前实现现状。当前支持方向是 C++
> `UINTERFACE(BlueprintType)` 自动绑定、脚本类实现 native UInterface、
> `Cast<UCppInterface>(Obj)` 和接口方法 bridge 调用；脚本
> `UINTERFACE()` / `interface UIFoo {}` 声明已废弃，不应再新增测试或示例。
> 后续若继续执行本计划，应先按当前 native-interface 实现重写范围与验收项。

## 背景与目标

### 背景

历史版本曾实现过一条 **脚本定义 UINTERFACE** 管线（详见仓库内接口分析资料；若需本地外部分析文档路径，统一通过 `Reference/README.md` 或本机配置索引查询，而不是在计划中写死绝对路径），但该方向已经回退并废弃：

- **预处理器**：识别 `interface` chunk → 提取方法声明到 `InterfaceMethodDeclarations` → 擦除接口块（保留行号空格） → `RegisterObjectType`（引用类型）+ `RegisterObjectMethod`（`CallInterfaceMethod` 回调）
- **类生成器**：创建接口 `UClass`（`CLASS_Interface | CLASS_Abstract`）+ minimal UFunction 存根 → `ResolveInterfaceClass` + `AddInterfaceRecursive` → `FindFunctionByName` 方法完整性校验
- **运行时**：`Cast<I>` 走 `ImplementsInterface` 分支 → `CallInterfaceMethod` 通用 generic 回调 → `FindFunction` → `ProcessEvent`
- **测试**：`Interface/` 目录下 15 个接口测试（Declare 2 / Implement 3 / Cast 3 / Advanced 7），测试路径 `Angelscript.TestModule.Interface.*`

这是一套 **插件侧模拟方案**——不走 AngelScript 引擎自带的 `interface` 编译路径，接口块在编译前被预处理器擦除，接口在 AS 编译器眼中是普通引用类型。

### 已知限制（来自 `AngelPortV2-UInterface-Support-Analysis.md` §6）

| 限制 | 说明 | 影响 |
|------|------|------|
| **UFunction 存根仅含名字** | Full Reload 生成的接口 UFunction 没有完整 `FProperty` 参数链 | 方法校验只靠 `FindFunctionByName` 同名匹配，不检查签名兼容性 |
| **FInterfaceProperty 未参与** | 运行时绑定层无 `FInterfaceProperty` 处理，编辑器侧相关代码已注释 | 无法在 AS 脚本属性中声明 `TScriptInterface<I>` 类型 |
| **TScriptInterface 未暴露** | 仅出现在自动生成的引擎 API caller 中 | 脚本侧不能用 `TScriptInterface<I>` 做属性存储和传递 |
| **接口块不进入 AS 编译** | 由预处理器擦除 + 插件侧模拟，非 AS 引擎原生 `interface` | 不能使用 AS 原生接口语法特性（如虚函数表） |
| **方法签名不做类型匹配** | 校验只检查方法名存在，不校验参数类型/个数 | 理论上方法名相同但签名不同也会通过编译 |

### C++ UInterface 支持缺口（历史状态，来自同文档 §6.2）

该小节记录的是 C++ UInterface 自动绑定落地前的历史缺口。当前脚本类已经可以实现 C++ 侧通过 `UINTERFACE(BlueprintType)` 声明的 UInterface，并可通过 `Cast<UCppInterface>(Obj)` 调用已绑定接口方法；继续推进时应重新盘点剩余缺口，而不是恢复脚本 `UINTERFACE()` 声明。

| # | 缺口 | 说明 |
|---|------|------|
| 1 | **未注册为 AS 类型** | C++ UInterface 没有通过 `RegisterObjectType` 注册到 AS 引擎，脚本中 `Cast<ICppInterface>()` 无法编译 |
| 2 | **方法未注册** | C++ 接口的 `UFUNCTION` 方法没有对应的 `CallInterfaceMethod` 注册，无法通过接口引用调方法 |
| 3 | **StaticClass() 不可用** | C++ 接口的 `StaticClass()` 全局变量未在 AS 中生成，脚本无法引用 `UMyInterface::StaticClass()` |

### Patch 方案参考（来自现有接口对比分析资料）

现有 `dev-as-interface` Patch 方案提供了一套完整的替代路线，核心差异如下：

| 维度 | AngelPortV2（当前） | Patch 方案 |
|------|-------------------|-----------|
| AS 接口模型 | 插件侧模拟：`RegisterObjectType` 引用类型 | AS 引擎原生：`RegisterInterface` 真正的 AS interface 类型 |
| 接口块处理 | 预处理器**擦除**，不进入 AS 编译器 | **保留**给 AS 编译器原生处理 |
| C++ UInterface | 不支持 | 全面支持，自动注册为 AS interface 类型 |
| FInterfaceProperty | 未参与 | 完整支持，包括属性创建/匹配/读写/getter/setter |
| ThirdParty 修改 | 无（零侵入） | 需修改 3 个 AS 引擎文件 |

Patch 方案的关键可借鉴技术点：
- **双重注册模式**：`UMyInterface`（UObject handle 兼容）+ `IMyInterface`（AS interface 新增）
- **FScriptInterface 桥接**：AS 侧始终使用 `UObject*`，在 UE 反射边界自动转换
- **接口方法继承链接**：`InheritNativeInterfaceMembers` 递归处理接口继承链
- **TypeFinder 扩展**：`FInterfaceProperty` → `FAngelscriptTypeUsage::FromClass(InterfaceClass)`

### 横向参考

- **UnrealCSharp**（见 `Reference/README.md` 中的 UnrealCSharp 条目）：双形态映射（`partial class U…` + `interface I…`），`FDynamicInterfaceGenerator` 动态创建接口 `UClass`，`FInterfacePropertyDescriptor` 完整属性支持，`UClass::Interfaces.Emplace(...)` 维护实现关系
- **PythonScriptPlugin**（引擎内置 Experimental 插件，可通过 `Paths.EngineRoot` 对应的引擎源码树查询）：`GetExportedInterfacesForClass` 递归收集接口 `UClass`，接口方法"混入"实现类 Python API，`FInterfaceProperty` 通过 `GetInterfaceAddress` 构造 `FScriptInterface`

### 目标

1. **决定架构方向**：确定是否修改 ThirdParty、命名约定、FInterfaceProperty 优先级
2. **实现 C++ UInterface 脚本绑定**：补齐三个缺口，脚本能 Cast、调方法、作属性引用 C++ 接口
3. **实现 FInterfaceProperty 支持**：`TScriptInterface<T>` 属性能在脚本中读写
4. **增强方法签名校验**：编译期检测签名不匹配
5. **补齐测试与文档**：验证所有新增能力，明确支持边界

## 当前事实状态

```text
脚本自定义接口方案已经废弃；以下历史实现点不再作为当前能力目标：
Preprocessor interface 块解析 / 方法提取 / 块擦除
ClassGenerator 动态创建脚本接口 UClass
脚本 `UINTERFACE()` + `interface UIFoo {}` 声明

当前接口测试（AngelscriptTest/Interface/）：
  AngelscriptInterfaceNativeTests.cpp
  AngelscriptInterfaceNativeBridgeTests.cpp
  AngelscriptInterfaceNativeBindingTests.cpp
  AngelscriptInterfaceNativeLifecycleTests.cpp
  AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp
  AngelscriptInterfaceNativePointerOffsetTests.cpp

AngelscriptTest/Angelscript/
  AngelscriptInheritanceTests.cpp           ← 语言级 interface 负例（期望编译失败）
```

能力边界：
- 脚本定义 `UINTERFACE()` / `interface UIFoo {}` → **已废弃，不支持，不应新增测试或示例**
- C++ 定义 `UInterface` + 脚本类实现 → **当前支持方向，测试覆盖 native implement / bridge / lifecycle / inherited surface / pointer offset**
- `TScriptInterface<T>` 属性 → **未支持**
- AS 语言级 `interface I…` → **明确不支持**
- 接口方法签名完整性 → **按 native UInterface 绑定路径继续验证；不恢复脚本自定义接口的签名匹配模型**

## 架构决策点

在开始分阶段执行之前，需确认以下三个决策点。Phase 0 的任务就是完成这些决策。

### 决策 1：是否修改 ThirdParty

| 选项 | 代价 | 收益 |
|------|------|------|
| **A：不修改**（当前策略） | 无升级风险 | 只能用 `RegisterObjectType` + `CallInterfaceMethod` 模拟，无 AS 编译器级类型检查 |
| **B：修改 `as_objecttype.cpp`** | 1 处修改（启用 `IsInterface()`），升级时需合入 | 获得 AS 原生 interface 语义，`RegisterInterface` 可用 |
| **C：全量采纳 Patch 的 3 处修改** | `as_objecttype.cpp` + `as_builder.cpp` x2 | 最完整：AS 编译器自动处理接口继承和方法契约 |

### 决策 2：命名约定

| 选项 | 示例 | 兼容性 |
|------|------|--------|
| **A：仅 U 前缀**（当前策略） | `UTestDamageableInterface` | 向后兼容，但 AS 编译器不识别接口语义 |
| **B：双重注册 U+I**（Patch 方案） | `UTestDamageableInterface`（handle）+ `ITestDamageableInterface`（interface） | 兼容现有代码 + 新增接口语义 |
| **C：仅 I 前缀** | `ITestDamageableInterface` | 与 UE C++ 习惯一致，但破坏向后兼容 |

### 决策 3：FInterfaceProperty 优先级

| 选项 | 说明 |
|------|------|
| **先跳过** | Phase 先只做 C++ 接口的 Cast + 方法调用，FInterfaceProperty 后续单独做 |
| **一起做** | 一次性完成全部 FInterfaceProperty 支持（Patch 改动约 200 行在 `Bind_BlueprintType.cpp`） |

## 分阶段执行计划

### Phase 0：架构决策与方案定型

> 目标：完成三个架构决策点，确定后续 Phase 的技术路线。

- [ ] **P0.1** 评估 ThirdParty 修改的可行性
  - 对照 Patch 的 3 处 AS 引擎修改（`as_objecttype.cpp` `IsInterface()` 启用、`as_builder.cpp` `CreateDefaultDestructors` null 检查、`as_builder.cpp` `DetermineTypeRelations` 接口继承）
  - 评估对当前 AS 2.33 和计划中 AS 2.38 升级的影响
  - 确认修改是否与 `P5-C-AS238-Migration-Plan.md` / `P9-A-Upgrade-Roadmap.md` 冲突
  - 参考现有接口对比分析资料 §4 优劣势对比
  - 记录决策结果到本 Plan 的"已确定决策"章节（新增）
- [ ] **P0.1** 📦 Git 提交：`[Interface] Docs: record ThirdParty modification decision`

- [ ] **P0.2** 确定命名约定和 FInterfaceProperty 优先级
  - 基于决策 1 结果选择命名约定（若选 B 用双重注册则需 Patch 式 `GetNativeInterfaceScriptName` U→I 转换）
  - 确定 FInterfaceProperty 是否与 C++ UInterface 同期实现
  - 更新本 Plan，将不适用的 Phase 标记为 N/A 或调整内容
- [ ] **P0.2** 📦 Git 提交：`[Interface] Docs: finalize naming convention and FInterfaceProperty priority`

### Phase 1：C++ UInterface 脚本绑定 — 类型注册

> 目标：让 C++ 定义的 UInterface 在 AS 脚本中可见，解决缺口 1（未注册为 AS 类型）和缺口 3（StaticClass 不可用）。

**方案 A（零 ThirdParty，`RegisterObjectType` 模拟）：**

- [ ] **P1.1** 在 `Bind_BlueprintType.cpp` 的 `BindUClass` 流程中，对 `IsNativeInterfaceClass(Class)` 的 UClass 额外注册 AS 类型
  - 参考 Patch 的 `IsNativeInterfaceClass` 判定（`CLASS_Interface` + 非 `UInterface::StaticClass()`）
  - 使用 `RegisterObjectType` 注册（当前模拟模式）或 `RegisterInterface`（若决策 1 选 B/C）
  - 确保 `UserData` 设置为对应 `UClass*`（与 `ApplyUnrealClassMetadataToScriptType` 模式一致）
- [ ] **P1.1** 📦 Git 提交：`[Interface] Feat: register C++ UInterface as AS type in BindUClass`

**方案 B（修改 ThirdParty，`RegisterInterface` 原生）：**

- [ ] **P1.1-alt** 先应用 `as_objecttype.cpp` 的 `IsInterface()` 启用修改
  - 修改内容：将注释掉的 `if ((flags & asOBJ_SCRIPT_OBJECT) && size == 0) return true;` 取消注释
  - 使用 `//[UE++]` / `//[UE--]` 标记
  - 然后在 `BindUClass` 中使用 `RegisterInterface` 而非 `RegisterObjectType`
- [ ] **P1.1-alt** 📦 Git 提交：`[ThirdParty] Feat: enable AS native interface semantics for IsInterface()`

- [ ] **P1.2** 确保 C++ 接口的 `StaticClass()` 全局变量在 AS 中可用
  - 确认 `BindStaticClass` 是否已为接口类型生成（当前 `BindUClass` 之后会调 `BindStaticClass`）
  - 若未覆盖，参考 Patch 的 `BindStaticClass` 调用逻辑补齐
  - 验证脚本中 `UMyInterface::StaticClass()` 可编译
- [ ] **P1.2** 📦 Git 提交：`[Interface] Feat: ensure C++ UInterface StaticClass() accessible in script`

- [ ] **P1.3** 注册类型别名（若决策 2 选 B 双重注册）
  - 参考 Patch：`FAngelscriptType::RegisterAlias(InterfaceTypeName, Type)`
  - 使 `UMyInterface`（handle）和 `IMyInterface`（interface）均可在脚本中使用
  - 若决策 2 选 A 或 C 则跳过此步
- [ ] **P1.3** 📦 Git 提交：`[Interface] Feat: register U/I dual name alias for C++ UInterface`

### Phase 2：C++ UInterface 脚本绑定 — 方法注册

> 目标：为 C++ UInterface 的方法注册 AS 调用入口，解决缺口 2（方法未注册）。

- [ ] **P2.1** 实现 C++ 接口方法扫描与注册
  - 参考 Patch 的 `BindNativeInterfaceMethods` 和 `ShouldBindNativeInterfaceFunction`
  - 遍历 C++ 接口 `UClass` 上的 `TFieldIterator<UFunction>`，过滤 `FUNC_BlueprintEvent | FUNC_BlueprintCallable | FUNC_BlueprintPure` 等
  - 为每个方法注册对应的 AS 入口：
    - 若方案 A（模拟）：使用 `RegisterObjectMethod` + `CallInterfaceMethod` + `FInterfaceMethodSignature`
    - 若方案 B（原生）：使用 `RegisterInterfaceMethod`（Patch 的 `RegisterNativeInterfaceMethodDeclaration`）
- [ ] **P2.1** 📦 Git 提交：`[Interface] Feat: register C++ UInterface methods for script access`

- [ ] **P2.2** 实现接口方法继承链接
  - 参考 Patch 的 `InheritNativeInterfaceMembers` + `LinkNativeInterfaceInheritanceRecursive`
  - 确保子接口继承父接口的所有方法（去重）
  - 处理 `UClass::GetSuperClass()` 沿 interface 继承链的递归
- [ ] **P2.2** 📦 Git 提交：`[Interface] Feat: link C++ interface inheritance chain for method visibility`

- [ ] **P2.3** 更新 `Bind_UObject.cpp` 中 `opCast` 的接口分支
  - 参考 Patch 简化写法（逻辑等价但更清晰）：
    ```cpp
    const bool bCanCast = AssociatedClass->HasAnyClassFlags(CLASS_Interface)
        ? Object->GetClass()->ImplementsInterface(AssociatedClass)
        : Object->IsA(AssociatedClass);
    ```
  - 确保 C++ 接口的 `ScriptType->GetUserData()` 能正确解析到 `UClass*`
- [ ] **P2.3** 📦 Git 提交：`[Interface] Refactor: simplify opCast interface branch`

### Phase 3：C++ UInterface 测试验证

> 目标：为 C++ UInterface 脚本绑定建立完整测试覆盖。

- [ ] **P3.1** 在 `AngelscriptTest/Shared/` 创建 C++ 测试 UInterface
  - 声明 `UTestNativeInterface` / `ITestNativeInterface`，包含 2-3 个 `UFUNCTION(BlueprintCallable)` 方法
  - 声明 `UTestNativeChildInterface` / `ITestNativeChildInterface`（继承前者），包含 1 个额外方法
  - 更新 `AngelscriptTest.Build.cs` 确保头文件可见
- [ ] **P3.1** 📦 Git 提交：`[Test/Interface] Feat: add C++ UInterface test fixtures`

- [ ] **P3.2** 创建 `Interface/AngelscriptCppInterfaceTests.cpp`，覆盖 7 个用例
  - `CppInterface.RegisterType` — C++ 接口在 AS 中作为类型可见（编译含该类型变量的脚本）
  - `CppInterface.StaticClass` — 脚本中 `UTestNativeInterface::StaticClass()` 非空
  - `CppInterface.Implement` — 脚本类声明实现 C++ 接口，编译成功
  - `CppInterface.ImplementsInterface` — C++ 侧 `ImplementsInterface(UTestNativeInterface::StaticClass())` 返回 true
  - `CppInterface.CastSuccess` — `Cast<UTestNativeInterface>(ScriptActor)` 非空
  - `CppInterface.CastFail` — 未实现该接口的对象 Cast 返回 nullptr
  - `CppInterface.CallMethod` — 通过接口引用调用方法，验证脚本实现被执行并返回正确值
- [ ] **P3.2** 📦 Git 提交：`[Test/Interface] Feat: add C++ UInterface binding scenario tests (7 cases)`

- [ ] **P3.3** 创建 `Interface/AngelscriptCppInterfaceAdvancedTests.cpp`，覆盖高级场景
  - `CppInterface.ChildInterface` — 脚本类实现 C++ 子接口，自动满足父接口 `ImplementsInterface`
  - `CppInterface.MissingMethod` — 脚本类声明实现 C++ 接口但缺少方法，编译报错
  - `CppInterface.MultipleNativeInterfaces` — 脚本类同时实现多个 C++ 接口
  - `CppInterface.MixedInterfaces` — 脚本类同时实现 C++ 接口和脚本接口
- [ ] **P3.3** 📦 Git 提交：`[Test/Interface] Feat: add C++ UInterface advanced scenario tests`

- [ ] **P3.4** 运行全部接口测试，确认通过并回归
  - 运行 `Angelscript.TestModule.Interface.*`（现有 15 个）
  - 运行 `Angelscript.TestModule.CppInterface.*`（新增 11 个）
- [ ] **P3.4** 📦 Git 提交：`[Test/Interface] Test: verify all interface tests pass including C++ binding`

### Phase 4：FInterfaceProperty 支持

> 目标：实现 `TScriptInterface<T>` 属性类型在脚本中的读写支持。

- [ ] **P4.1** 扩展 `Bind_BlueprintType.cpp` 中 `FUObjectType` 的 `CreateProperty`
  - 当 `AssociatedClass` 带 `CLASS_Interface` 时，创建 `FInterfaceProperty` 而非 `FObjectProperty`
  - 参考 Patch 实现：`new FInterfaceProperty(...)` + `SetInterfaceClass(AssociatedClass)`
- [ ] **P4.1** 📦 Git 提交：`[Interface] Feat: emit FInterfaceProperty for interface type UPROPERTY`

- [ ] **P4.2** 扩展 `FUObjectType::MatchesProperty` 以匹配 `FInterfaceProperty`
  - 参考 Patch：`CastField<FInterfaceProperty>(Property)` → 检查 `InterfaceClass` 一致性
- [ ] **P4.2** 📦 Git 提交：`[Interface] Feat: match FInterfaceProperty in type system`

- [ ] **P4.3** 扩展 `FUObjectType::SetArgument` 和 `GetReturnValue` 以处理 `FScriptInterface` 桥接
  - `SetArgument`：从 `FScriptInterface*` 读取 `GetObject()` 传入 AS
  - `GetReturnValue`：将 AS 返回的 `UObject*` 包装为 `FScriptInterface`（`SetObject` + `SetInterface(GetInterfaceAddress)`）
  - 参考 Patch 的 `FScriptInterface` 桥接模式
- [ ] **P4.3** 📦 Git 提交：`[Interface] Feat: bridge FScriptInterface in argument and return value paths`

- [ ] **P4.4** 扩展 `FUObjectType::BindProperty` 为接口属性生成 Get/Set 访问器
  - Getter：通过 `FScriptInterface::GetObject()` 返回 `UObject*`
  - Setter：将 `UObject*` + `ImplementsInterface` 验证后写入 `FScriptInterface`
  - 参考 Patch 在 `Bind_Helpers.h` 中新增的 4 个 helper 函数：
    - `GetInterfaceObjectFromProperty`
    - `GetValueFromPropertyGetter_InterfaceHandle`
    - `SetInterfaceObjectFromProperty`
    - `SetInterfaceObjectFromPropertySetter`
- [ ] **P4.4** 📦 Git 提交：`[Interface] Feat: generate Get/Set accessors for interface properties`

- [ ] **P4.5** 扩展 TypeFinder 以识别 `FInterfaceProperty`
  - 参考 Patch 在 `BindUClassLookup` 中新增的 TypeFinder lambda
  - `CastField<FInterfaceProperty>(Property)` → `FAngelscriptTypeUsage::FromClass(InterfaceClass)`
  - 使 C++ 侧声明的 `TScriptInterface<IFoo>` 属性自动映射到 AS 接口类型
- [ ] **P4.5** 📦 Git 提交：`[Interface] Feat: extend TypeFinder to recognize FInterfaceProperty`

- [ ] **P4.6** 创建 `Interface/AngelscriptInterfacePropertyTests.cpp`，覆盖：
  - `InterfaceProperty.Get` — 读取 C++ 类上的 `TScriptInterface<T>` 属性
  - `InterfaceProperty.Set` — 设置接口属性，赋值实现了接口的对象
  - `InterfaceProperty.SetInvalid` — 赋值未实现接口的对象，验证安全处理
  - `InterfaceProperty.CallThrough` — 通过属性获取的接口引用调用方法
  - `InterfaceProperty.Null` — 空引用的安全处理
  - `InterfaceProperty.WithGetter` — 带自定义 Getter 的接口属性
  - `InterfaceProperty.WithSetter` — 带自定义 Setter 的接口属性
- [ ] **P4.6** 📦 Git 提交：`[Test/Interface] Feat: add FInterfaceProperty scenario tests (7 cases)`

- [ ] **P4.7** 运行全部接口测试 + 回归现有测试，确认通过
- [ ] **P4.7** 📦 Git 提交：`[Interface] Test: verify FInterfaceProperty support and regression`

### Phase 5：方法签名校验增强

> 目标：增强方法签名匹配，从仅名字匹配升级为参数类型校验。

- [ ] **P5.1** 改进 `FinalizeClass` 中的方法完整性校验
  - 当前仅 `FindFunctionByName` 同名匹配，改为额外校验参数数量和类型
  - 对照接口 UFunction 存根的 `FProperty` 链与实现类 UFunction 的 `FProperty` 链
  - 若 UFunction 存根为 minimal（无 `FProperty`），先跳过签名校验（不退化现有行为）
- [ ] **P5.1** 📦 Git 提交：`[Interface] Feat: add parameter signature validation in FinalizeClass`

- [ ] **P5.2** 改进接口 UFunction 存根生成质量
  - 在 `DoFullReloadClass` 中，将 minimal UFunction（仅 `FuncName`）升级为带完整 `FProperty` 参数链
  - 从 `InterfaceMethodDeclarations` 解析参数类型并创建对应 `FProperty`
  - 确保 full reload 和新建类两条路径一致
- [ ] **P5.2** 📦 Git 提交：`[Interface] Feat: generate full-signature UFunction stubs for interface methods`

- [ ] **P5.3** 创建 `Interface/AngelscriptInterfaceSignatureTests.cpp`，覆盖：
  - `Signature.Match` — 正确签名实现通过
  - `Signature.ArgCountMismatch` — 参数数量不同报错
  - `Signature.ArgTypeMismatch` — 参数类型不同报错
  - `Signature.ReturnTypeMismatch` — 返回类型不同报错
- [ ] **P5.3** 📦 Git 提交：`[Test/Interface] Feat: add interface signature validation tests (4 cases)`

- [ ] **P5.4** 回归全部接口测试，确认通过
- [ ] **P5.4** 📦 Git 提交：`[Interface] Test: verify signature enhancement regression`

### Phase 6：预处理器增强（若采用 Patch 式接口保留）

> 目标：若决策 1 选 B/C（修改 ThirdParty），增强预处理器使接口块进入 AS 编译器。仅当选方案 B/C 时执行此 Phase，否则标记 N/A。

- [ ] **P6.1** 修改预处理器不再擦除接口块
  - 接口块内容保留给 AS 编译器原生处理
  - 仍需提取 `InterfaceMethodDeclarations` 供 ClassGenerator 使用
  - 参考 Patch 在 `DetectClasses` / `AnalyzeClasses` / `ParseIntoChunks` 中对 `EChunkType::Interface` 的处理
- [ ] **P6.1** 📦 Git 提交：`[Interface] Feat: preserve interface blocks for AS compiler`

- [ ] **P6.2** 应用 `as_builder.cpp` 的两处修改（若决策 1 选 C）
  - `CreateDefaultDestructors`：跳过接口类型 + null 检查
  - `DetermineTypeRelations`：当脚本类继承 interface 时调 `AddInterfaceToClass`
  - 使用 `//[UE++]` / `//[UE--]` 标记，记录到 `AngelscriptChange.md`
- [ ] **P6.2** 📦 Git 提交：`[ThirdParty] Feat: AS builder interface inheritance and destructor handling`

- [ ] **P6.3** 处理隐式 UObject 基类（脚本类只列接口作为父类时）
  - 参考 Patch 的 `bImplicitObjectBaseFromInterfaces` 逻辑
  - 当 `class Foo : IBar` 时自动设为 `UObject` 基类 + 实现 `IBar`
- [ ] **P6.3** 📦 Git 提交：`[Interface] Feat: implicit UObject base for interface-only inheritance`

- [ ] **P6.4** 回归全部接口和非接口测试，确认无引入失败
- [ ] **P6.4** 📦 Git 提交：`[Interface] Test: verify preprocessor enhancement regression`

### Phase 7：文档与测试指南同步

> 目标：更新相关文档，明确接口功能的支持范围和使用方法。

- [ ] **P7.1** 在 `Documents/Knowledges/` 下创建 `InterfaceBinding.md` 知识文档
  - 脚本语法示例（声明、实现、Cast、属性、C++ 接口绑定）
  - 支持的接口功能完整列表
  - 已知限制（AS 语言级 interface 不支持等）
  - 架构决策记录（选了哪个方案、为什么）
  - 与 Patch 方案 / UEAS2 的差异说明
- [ ] **P7.1** 📦 Git 提交：`[Docs] Feat: add InterfaceBinding knowledge document`

- [ ] **P7.2** 更新 `Documents/Guides/Test.md`，补充接口测试分类
  - 现有 15 个脚本接口测试说明
  - 新增 C++ 接口绑定测试说明
  - 新增 FInterfaceProperty 测试说明
  - 测试命名规范
- [ ] **P7.2** 📦 Git 提交：`[Docs] Feat: update test guide with interface test categories`

- [ ] **P7.3** 在 `Agents_ZH.md` 补充接口绑定功能说明
  - 1-2 句简述当前接口支持范围
  - 指向 `Documents/Knowledges/InterfaceBinding.md`
- [ ] **P7.3** 📦 Git 提交：`[Docs] Chore: mention interface binding in Agents_ZH`

## 验收标准

1. **C++ UInterface 脚本绑定**：C++ 定义的 UInterface 在 AS 脚本中可见，能 Cast、调方法、引用 StaticClass（≥11 个新增场景测试通过）
2. **FInterfaceProperty 支持**：`TScriptInterface<T>` 属性能在脚本中读写并通过接口引用调方法（≥7 个新增测试通过），或有明确的"延后"决策文档
3. **方法签名校验**：接口方法签名不匹配时编译期给出诊断（≥3 个签名错误测试通过）
4. **回归通过**：现有 15 个 Scenario 接口测试全部回归通过
5. **架构决策文档化**：ThirdParty 修改决策、命名约定、FInterfaceProperty 优先级均有明确记录
6. **知识文档**：`Documents/Knowledges/InterfaceBinding.md` 明确描述支持范围、语法、限制

## 风险与注意事项

### 风险 1：ThirdParty 修改与 AS 2.38 升级冲突

若选方案 B/C 修改 AS 引擎代码，`P7`（AS 2.33→2.38 升级）时需重新合入。`IsInterface()` 在 2.38 中的代码位置可能变化。

**缓解**：修改点使用 `//[UE++]` / `//[UE--]` 标记，记录到 `AngelscriptChange.md`。决策前对照 `P9-A-Upgrade-Roadmap.md` 和 `P5-C-AS238-Breaking-Changes.md` 评估冲突面。

### 风险 2：C++ UInterface 名称映射

`FAngelscriptType::GetBoundClassName` 返回的类名可能包含前缀或模块名。Patch 使用 `TypeName[0] = 'I'` 做 U→I 转换，假设首字符一定是 `U`。

**缓解**：Phase 1 中添加 `check()` 验证首字符假设。对非标准命名的接口（如不以 U 开头）有兜底逻辑。

### 风险 3：FScriptInterface 双指针布局

UE 的 `FScriptInterface` 持 `ObjectPointer` + `InterfacePointer`。脚本实现（`PointerOffset = 0`）两者相同，C++ native 实现两者不同。

**缓解**：Phase 4 实现时，参考 Patch 的 `GetInterfaceAddress` 模式，始终通过 `UObject::GetInterfaceAddress(InterfaceClass)` 获取正确偏移，不假设 `PointerOffset = 0`。

### 风险 4：BindDB 双路径

Patch 代码中有 `#if AS_USE_BIND_DB` / `#else` 双路径。当前 AngelPortV2 需确认使用哪条路径。

**缓解**：Phase 2 实现前确认 `AS_USE_BIND_DB` 在当前构建中的状态，仅实现对应路径。

### 风险 5：接口注册时机

`BindUClass` 的调用顺序可能导致接口类型在方法注册时尚未可见。Patch 通过两轮遍历解决：先注册所有接口方法，再链接继承。

**缓解**：Phase 2 参考 Patch 的两轮遍历模式（先 `BindNativeInterfaceMethods`，再 `LinkNativeInterfaceInheritance`）。

## 依赖关系

```text
Phase 0（架构决策）
  ↓
Phase 1（C++ UInterface 类型注册）── 依赖 Phase 0 的方案选择
  ↓
Phase 2（C++ UInterface 方法注册）── 依赖 Phase 1
  ↓
Phase 3（C++ UInterface 测试）── 依赖 Phase 1+2
  ↓
Phase 4（FInterfaceProperty）── 依赖 Phase 1+2 的基础设施
  ↓                               可与 Phase 5 并行调研
Phase 5（签名校验增强）── 依赖 Phase 3 的回归基线
  ↓
Phase 6（预处理器增强）── 仅方案 B/C，依赖 Phase 0
  ↓                       与 Phase 1-5 可能交替进行
Phase 7（文档）── 依赖所有前置 Phase 的结论
```

## 参考文档索引

| 文档 | 位置 | 用途 |
|------|------|------|
| AngelPortV2 UInterface 支持方案分析 | `J:\UnrealEngine\Docs\Angelscript\AngelPortV2-UInterface-Support-Analysis.md` | 当前实现的完整分析、已知限制、C++ UInterface 缺口 |
| AngelPortV2 vs Patch 接口方案对比 | `J:\UnrealEngine\Docs\Angelscript\AngelPortV2-vs-Patch-Interface-Comparison.md` | 两种架构的优劣势、决策参考 |
| dev-as-interface Patch | `J:\UnrealEngine\Docs\参考-dev-as-interface-interface-improvements.patch` | Patch 完整实现代码，各层改动参考 |
| AS 2.38 升级路线图 | `J:\UnrealEngine\Docs\Angelscript\P9-A-Upgrade-Roadmap.md` | ThirdParty 修改与升级兼容性评估 |
| AS 2.38 Breaking Changes | `J:\UnrealEngine\Docs\Angelscript\P5-C-AS238-Breaking-Changes.md` | ThirdParty 修改冲突面评估 |
| UnrealCSharp 接口实现 | `Reference/UnrealCSharp` | 横向参考：双形态映射、FDynamicInterfaceGenerator |
