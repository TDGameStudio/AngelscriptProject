# 接口与 C++ UInterface 使用一致性补齐计划

## 背景与目标

### 背景

当前 Angelscript 插件已经实现了完整的"脚本定义 `UINTERFACE`"管线与"C++ `UINTERFACE` 自动绑定"管线（详见 `Plan_CppInterfaceBinding.md`、`Documents/Knowledges/InterfaceBinding.md`）。现有 36+ 接口测试全部通过，脚本能声明接口、`Cast<>`、通过接口引用调方法、`ImplementsInterface(UClass)` 查询，C++ UInterface 也能在脚本中被自动看见并调用。

但脚本侧的接口**使用体验与 C++ UInterface 的习惯仍有明显不一致**，集中体现在 5 个层面：

| # | 不一致点 | 现状 | C++ 习惯 |
|---|---------|------|---------|
| 1 | 方法签名校验 | `FInterfaceMethodSignature` 仅 `FName FunctionName`，`FinalizeClass` 仅按函数名匹配（`Core/AngelscriptEngine.h:59-62`） | UHT 在编译期做参数数量、参数类型、const 限定、返回值全匹配 |
| 2 | `TScriptInterface<I>` 属性与参数 | `FInterfaceProperty` 未参与绑定，脚本不能声明 `UPROPERTY TScriptInterface<UIFoo>` 或以此为 UFUNCTION 参数 | 标准 UE 做法，`FScriptInterface` 双字段桥接 |
| 3 | C++ 原生实现类的指针偏移 | `Bind_UObject.cpp` opCast 接口分支直接 `*(UObject**)OutAddress = Object`（约 188-213 行），未调用 `UObject::GetInterfaceAddress(InterfaceClass)` | `Cast<IFoo>(Obj)` 返回带偏移的 `IFoo*`；`FScriptInterface::SetInterface` 按偏移设置 |
| 4 | `BlueprintNativeEvent` / `BlueprintImplementableEvent` | 预处理器跳过接口块内的 `UFUNCTION()` 修饰符，生成的 UFunction 存根没有 `FUNC_BlueprintEvent` / `FUNC_Native` 等 flags | 接口方法可标 `BlueprintNativeEvent`，脚本/蓝图 override 与 C++ `_Implementation` 能共存分发 |
| 5 | `Obj.Implements<T>()` 泛型 | 只提供 `Obj.ImplementsInterface(UClass)`（`Bind_UObject.cpp:100-106`） | C++ 模板 `Obj->Implements<UFoo>()` 更自然 |

本计划不做破坏性命名迁移（保留脚本接口 `UI` 双字前缀、C++ 接口仍以 `U` 前缀 UClass 名引用），也不追求 AS 原生 `interface` 语义，而是在现有"插件层模拟 + C++ 自动绑定"架构上做五个定点增强。

### 目标

1. **签名完整校验**：接口方法不匹配（参数数量/类型/返回值/const）时在 `FinalizeClass` 阶段就报错，并给出"期望签名 vs 实际签名"的可读日志。
2. **`TScriptInterface<I>` 桥接**：脚本 `UPROPERTY() TScriptInterface<UIFoo> Ref` 可读可写；UFUNCTION 参数/返回值为 `TScriptInterface<UIFoo>` 时跨 UE 反射边界正确传递。
3. **C++ 原生实现类指针偏移修复**：脚本中 `Cast<UMyInterface>(NativeActor)` 之后调用接口方法时 `this` 指针正确偏移；`TScriptInterface::InterfacePointer` 正确填写。
4. **接口方法事件语义**：接口声明支持 `UFUNCTION(BlueprintNativeEvent)` / `UFUNCTION(BlueprintImplementableEvent)` 修饰符；C++ 侧 `IFoo::Execute_MethodName(Obj, ...)` 分发脚本 override 或 C++ `_Implementation` 的语义与 UE 原生一致（脚本侧不额外提供 `Execute_` 语法糖）。
5. **`Obj.Implements<T>()` 泛型**：脚本能写 `Obj.Implements<UIFoo>()`、`Obj.Implements<UAngelscriptNativeParentInterface>()`；保留 `ImplementsInterface(UClass)` 向后兼容。

### 范围与边界

- **不做**：U/I 双前缀命名切换、`Execute_XXX` 脚本语法糖、AS 原生 `interface` 关键字启用、`as_builder.cpp` 接口继承改动。
- **ThirdParty 策略**：本计划**零新增 ThirdParty 修改**；现有 3 处 `CanCastScriptObjectToUnrealInterface` 注入保持不动。`as_tokendef.h::interface` 关键字、`as_objecttype.cpp::IsInterface()` 返回值均保持现状（见 Phase 0 决策与 `Documents/Guides/AngelscriptForkStrategy.md` "脚本 interface 不支持，仅原生注册"的结构性分叉点）。
- **向后兼容**：所有现有脚本无需修改；现有 36+ 接口测试零回归。

### 与已有 Plan 的关系

| 文档 | 关系 |
|------|------|
| `Plan_CppInterfaceBinding.md` | 已完成的前置（C++ UInterface 自动注册、方法绑定、继承链接） — 本计划是在其基础上的一致性补齐 |
| `Plan_InterfaceBinding.md` | 完整接口设计文档；本计划的 Phase 1/2/3 对应其 Phase 4/5，但决策点收敛（零 ThirdParty 修改），完成后需标注"Phase 4/5 已由本计划承接" |
| `Documents/Knowledges/InterfaceBinding.md` | 接口能力知识文档；本计划 Phase 6 负责同步更新"已知限制"的前后对比 |

## 当前事实状态

```text
接口相关代码分布：

Preprocessor/AngelscriptPreprocessor.h   ← EChunkType::Interface、InterfaceMethodDeclarations
Preprocessor/AngelscriptPreprocessor.cpp ← 接口块解析、方法提取、块擦除（当前丢弃 UFUNCTION 修饰符）
Core/AngelscriptEngine.h                 ← FInterfaceMethodSignature（仅 FName，本计划 Phase 1 扩展）
Core/AngelscriptEngine.cpp               ← RegisterInterfaceMethodSignature / ReleaseInterfaceMethodSignature（行 1261-1285）
ClassGenerator/AngelscriptClassGenerator.cpp
  ├─ CallInterfaceMethod（行 56-98）                    — this 指针装载、ProcessEvent 分发
  ├─ 接口 UClass 创建（行 2788-2861）                   — CLASS_Interface | CLASS_Abstract + minimal UFunction 存根
  ├─ FinalizeClass 接口挂接（行 5081-5209）             — 当前仅 FindFunctionByName 同名校验
  └─ DoFullReloadClass                                   — minimal UFunction 存根生成
Binds/Bind_UObject.cpp
  ├─ ImplementsInterface(UClass) 绑定（行 98-107）      — 本计划 Phase 5 新增 Implements<T>()
  └─ opCast 接口分支（行 188-213）                       — 本计划 Phase 3 走 GetInterfacePointerForCast
Binds/Bind_BlueprintType.cpp
  ├─ Bind_Defaults Phase 5 接口自动绑定                   — 已完成（Plan_CppInterfaceBinding）
  ├─ FUObjectType::CreateProperty                         — 本计划 Phase 2 扩展 FInterfaceProperty 分支
  ├─ FUObjectType::MatchesProperty/SetArgument/GetReturnValue/BindProperty
  └─ TypeFinder                                           — 本计划 Phase 2 识别 FInterfaceProperty

ThirdParty（仅列已有注入，本计划不新增）：
  as_scriptengine.cpp:5081 / 5094  — CanCastScriptObjectToUnrealInterface
  as_context.cpp:3296              — 运行时 CAST 指令
  as_objecttype.cpp::IsInterface() — 强制返回 false（fork 分叉点，不启用）
  as_tokendef.h::interface         — 关键字未启用（fork 分叉点，不启用）

测试分布：
  Interface/（13 个文件，33 个用例）
  Preprocessor/Interface（2）
  Compiler/Interface（1）
  Shared/AngelscriptNativeInterfaceTestTypes.h — 本计划 Phase 3 扩展 fixture
```

## 已确定决策（Phase 0 输出）

### 决策 1：ThirdParty 修改策略 → **零新增修改**

- `asCObjectType::IsInterface()` 当前强制 `return false`（`as_objecttype.cpp:284-290`），原逻辑 `(flags & asOBJ_SCRIPT_OBJECT) && size == 0` 被注释掉。
- 启用它会让 `as_builder.cpp` 进入接口路径（至少 8 处 `IsInterface()` 分支，涉及实例化拒绝、接口继承递归、虚属性处理、shared 检查），破坏现有"脚本 interface 通过预处理器擦除 + 插件层模拟"的架构。
- 这与 `Documents/Guides/AngelscriptForkStrategy.md` 明确列出的"脚本 `interface` 不支持，仅原生注册"结构性分叉点冲突。
- **结论**：本计划所有改动**完全在插件层完成**。

### 决策 2：命名约定 → **保持现状仅 U 前缀**

- 脚本定义接口仍写 `UINTERFACE() interface UIFoo { ... }`（`UI` 双字前缀）。
- C++ 接口在脚本中仍以 `U` 前缀 UClass 名引用（`UAngelscriptNativeParentInterface` 等）。
- 不做 U/I 双重注册、不做 I 前缀别名。

### 决策 3：ThirdParty 修改标记惯例 → **`[UE++]` 注释**

- 约定来自 `AngelscriptForkStrategy.md` "代码标记约定"章节。
- 仓库当前不存在 `AngelscriptChange.md`；所有 ThirdParty 改动通过 `[UE++]` / `[UE--]` 注释就地标注。
- 本计划不新增 ThirdParty 改动，但在风险控制段落保留"若意外需要则走 `[UE++]` 路径"的兜底。

### 决策 4：`Execute_XXX` 脚本语法糖 → **不做**

- 脚本侧继续用"`Cast<UIFoo>(Obj)` → 直接调方法"的链路。
- C++ 侧已有的 `IFoo::Execute_Method(Obj, ...)` 分发机制通过 Phase 4 的 UFunction flags 自动走 `ProcessEvent`，不需要在 AS 层暴露新语法。

## 分阶段执行计划

### Phase 0：架构决策与文档落地

> 目标：把上述 4 个决策写成权威文档，避免后续 Phase 执行时回头讨论。

- [x] **P0.1** 撰写 `Documents/Plans/Plan_InterfaceParityWithCpp.md`（即本文件）
  - 已确认 `asCObjectType::IsInterface()` 当前强制 `return false`（`as_objecttype.cpp:284-290`），启用会引发 `as_builder.cpp` 8+ 处接口路径联动，与 ForkStrategy 的"脚本 interface 不支持"结构性分叉点冲突
  - 已确认 `AngelscriptChange.md` 当前不存在；ThirdParty 修改惯例是 `[UE++]` 注释
  - 将现状、决策、Phase 拆分、验收、风险一次性落盘，作为 Phase 1-6 的唯一 source of truth
- [x] **P0.1** 📦 Git 提交：`[Interface] Docs: add Plan_InterfaceParityWithCpp with zero-ThirdParty decision`（commit `fc970bc`）

- [x] **P0.2** 在 `Documents/Plans/Plan_OpportunityIndex.md` 登记本计划，并在 `Plan_InterfaceBinding.md` 顶部加承接说明
  - `Plan_OpportunityIndex.md §4.1` 新增一行 `B2` 条目，指向本 Plan，状态"进行中（Phase 0 完成）"
  - `Plan_InterfaceBinding.md` 顶部新增"2026-04-24 承接说明"小节，标注 Phase 4/5 由本计划承接
  - `Plan_StatusPriorityRoadmap.md` 暂不改动：其"事实快照"文字较多且与本计划并无冲突，承接关系已通过 Plan_OpportunityIndex + Plan_InterfaceBinding 双入口充分表达
- [x] **P0.2** 📦 Git 提交：`[Docs] Chore: register InterfaceParityWithCpp in plan indexes`

### Phase 1：接口方法签名完整校验

> 目标：把"同名匹配"升级为"同名 + 参数类型/数量 + 返回类型 + const 限定"的全签名匹配，让实现类缺参或改参时在编译期就暴露。

- [x] **P1.1** 扩展 `FInterfaceMethodSignature`（`Core/AngelscriptEngine.h:59-62`）
  - 现状只存 `FName FunctionName`，`FinalizeClass` 的校验路径只能 `FindFunctionByName`，改签名的实现类编译期完全无感；运行时走到方法调用时才因类型不匹配崩溃或行为异常
  - 新增字段：`TArray<FAngelscriptTypeUsage> ParamTypes`、`FAngelscriptTypeUsage ReturnType`、`uint32 FunctionFlags = 0`、`bool bIsConst = false`、`bool bSignatureResolved = false`
  - `FAngelscriptTypeUsage` 已在 `Core/AngelscriptType.h` 定义并被 BlueprintType 绑定层大量复用，直接引用即可
  - 保留原 `RegisterInterfaceMethodSignature(FName)` 重载供预处理器占位使用；新增带完整参数的重载 + `PopulateInterfaceMethodSignature` setter，供后续 Phase 回写
- [x] **P1.1** 📦 Git 提交：`[Interface] Feat: expand FInterfaceMethodSignature with full param/return types`（commit `f8aff18`，构建 417/417 通过）

- [x] **P1.2** 签名生成：脚本定义接口路径
  - 预处理器阶段（`AngelscriptPreprocessor.cpp:1211`）只能拿到方法名 — 此时 AS method 尚未编译，`FromParam/FromReturn` 无法调用；保留原处的占位 `RegisterInterfaceMethodSignature(FName)` 不动
  - 真正的完整签名填充延迟到 `AngelscriptClassGenerator.cpp` 的接口 UFunction 生成循环（原行号 2962-3086）：每个方法生成 UFunction 的同时，把已收集的 `SignatureParamTypes`、`SignatureReturnType`、`NewFunction->FunctionFlags`、`(FunctionFlags & FUNC_Const) != 0` 通过 `ScriptMethod->GetUserData()` 取回 Signature 并调 `PopulateInterfaceMethodSignature` 写回
  - 不依赖字符串解析（原字符串只用于方法名提取），类型信息全部来自权威的 `asIScriptFunction` — 避免与 UFunction 生成路径漂移
- [x] **P1.2** 📦 Git 提交：`[Interface] Feat: fill signature from script interface declarations`（commit `19468d4`，增量构建通过）

- [x] **P1.3** 签名生成：C++ UInterface 自动绑定路径
  - `Bind_BlueprintType.cpp` 的 Phase 5 原本只向 `RegisterInterfaceMethodSignature(FName)` 传方法名；上下文中 `ReturnType`、`ArgumentTypes`、`Function->HasAnyFunctionFlags(FUNC_Const)`、`Function->FunctionFlags` 早就通过 `TFieldIterator<FProperty>(Function)` + `FAngelscriptTypeUsage::FromProperty` 准备完毕
  - 改走 P1.1 新增的完整签名 Register 重载，一次性落地 `ParamTypes/ReturnType/FunctionFlags/bIsConst/bSignatureResolved=true`
  - 这是最干净的入口点，不需要任何补齐逻辑，也无需读第二遍 `FProperty` 链
- [x] **P1.3** 📦 Git 提交：`[Interface] Feat: fill signature from C++ UInterface reflection`（commit `0fddf4a`，增量构建通过）

- [x] **P1.4** 升级 `FinalizeClass` 的接口方法校验
  - `ClassGenerator/AngelscriptClassGenerator.cpp` 在 `FinalizeClass` 的接口完整性校验段（沿 `ImplementedInterfaces` 遍历，原行号 5440-5458）里，把当前的 `FindFunctionByName` 单步扩展为"找到函数后对比签名"
  - 校验实现不走 `FInterfaceMethodSignature`，而直接读两端 UFunction 的 `FProperty` 链 — 接口 UFunction 两条生成路径都已自带完整 FProperty，绕过了"降级路径"讨论，实现更简单
  - 用 `FProperty::SameType` 做 canonical 比较；对 `FFloatProperty`/`FDoubleProperty` 互换做一次 narrow relaxation，原因：AS fork 的类型映射目前会让脚本接口端生成 `FFloatProperty`、实现类端生成 `FDoubleProperty`（这是一个 pre-existing 行为，不在本 Phase 修复）
  - 不匹配时给 `ScriptCompileError` 输出"期望签名 vs 实际签名"的可读 ProperyClass + 参数列表
- [x] **P1.4** 📦 Git 提交：`[Interface] Feat: FinalizeClass matches interface methods by full signature`（commit `876b865`，25/25 + 2/2 接口测试全部通过）

- [x] **P1.5** 升级 Full Reload 的 minimal UFunction 存根（已无需单独执行）
  - code-explorer 报告确认：脚本接口 UFunction 存根路径（`AngelscriptClassGenerator.cpp:2962-3086`）**早已**通过 `FAngelscriptTypeUsage::FromReturn/FromParam` + `AddFunctionReturnType`/`AddFunctionArgument` 生成完整 `FProperty` 链 — 并非 minimal
  - 真正 minimal 的是 **C++ UInterface 自动绑定路径**注册到 AS 侧的 method 存根，但那条路径引用的是 UHT 生成的 UFunction（自带完整 FProperty 链），脚本端可直接用
  - 因此 P1.4 采用的"读 UFunction FProperty 链进行签名对比"方案无需此 Phase 的额外铺垫；P1.5 转为文档记录
- [x] **P1.5** 📦 Git 提交：无代码改动，此 Phase 转为 Plan 文档记录（已被 P1.4 回归间接验证）

- [x] **P1.6** 新增 `AngelscriptInterfaceSignatureTests.cpp` 5 个用例
  - 放在 `Plugins/Angelscript/Source/AngelscriptTest/Interface/`，测试路径 `Angelscript.TestModule.Interface.Signature.*`
  - `Signature.ArgCountMismatch` — 实现方法少一个参数 → 编译期诊断 `"mismatching signature"`
  - `Signature.ArgTypeMismatch` — 参数类型 `int` → `FString` → 编译期诊断
  - `Signature.ReturnTypeMismatch` — 返回类型 `int` → `bool` → 编译期诊断
  - `Signature.ConstMismatch` — 接口方法标 const 但实现未标 → 编译期诊断
  - `Signature.ExactMatch` — 正确签名正例，验证无回归
- [x] **P1.6** 📦 Git 提交：`[Test/Interface] Feat: add interface signature validation tests`（commit `522cc58`，30/30 接口测试全通过）

### Phase 2：`TScriptInterface<I>` 属性与参数桥接

> 目标：脚本能声明 `UPROPERTY() TScriptInterface<UIFoo> Ref`，`UFUNCTION` 参数和返回值可用 `TScriptInterface<UIFoo>`，跨反射边界自动桥接 `FScriptInterface` 双字段。

- [ ] **P2.1** 新增双指针桥接助手
  - 在 `Binds/Bind_Helpers.h` 新增 `void* GetInterfacePointerForCast(UObject* Object, UClass* InterfaceClass)`：脚本实现类走快路径返回 `Object`，C++ 原生实现类调 `Object->GetInterfaceAddress(InterfaceClass)`，`InterfaceClass` 非 `CLASS_Interface` 或 `Object` 未实现时返回 `nullptr`
  - 同文件再加 4 个配套 helper：`GetInterfaceObjectFromProperty`、`SetInterfaceObjectFromProperty`、`GetValueFromPropertyGetter_InterfaceHandle`、`SetInterfaceObjectFromPropertySetter`，作为后续 P2.3/P2.4 的实现基石
  - 命名与现有 `Bind_Helpers.h` 风格保持一致（参考 `GetValueFromPropertyGetter_*` 系列）
- [ ] **P2.1** 📦 Git 提交：`[Interface] Feat: add interface pointer bridge helpers in Bind_Helpers`

- [ ] **P2.2** `FUObjectType::CreateProperty` 为接口类型产出 `FInterfaceProperty`
  - `Bind_BlueprintType.cpp` 的 `FUObjectType::CreateProperty`：当 `AssociatedClass->HasAnyClassFlags(CLASS_Interface)` 且不是 `UInterface::StaticClass()` 本身时，构造 `FInterfaceProperty`（`SetInterfaceClass(AssociatedClass)`）而不是 `FObjectProperty`
  - 仅用于当脚本侧写 `UPROPERTY() UIFoo Ref`（当前行为：生成 `FObjectProperty` 指向接口 UClass）时，改为符合 UE 习惯的 `FInterfaceProperty` — 这一步后续 Phase 会接到 TScriptInterface 语法糖
- [ ] **P2.2** 📦 Git 提交：`[Interface] Feat: emit FInterfaceProperty for interface UPROPERTY`

- [ ] **P2.3** `FUObjectType` 的参数/返回值/属性桥接扩展 `FInterfaceProperty` 分支
  - `MatchesProperty`：识别 `CastField<FInterfaceProperty>(Property)` 并校验 `InterfaceClass == AssociatedClass`
  - `SetArgument` / `GetReturnValue`：通过 `FScriptInterface` 读写 — 读时 `GetObject()` 返回 `UObject*` 给 AS；写时 `SetObject(Object)` + `SetInterface(Object->GetInterfaceAddress(InterfaceClass))`（即 P2.1 的 `GetInterfacePointerForCast`）
  - `BindProperty`：为接口属性生成 Get/Set 访问器 — Getter 返回 `FScriptInterface::GetObject()`；Setter 先校验 `ImplementsInterface`，通过后走双字段写入，不通过则 `ensure` + 静默跳过（不崩溃）
- [ ] **P2.3** 📦 Git 提交：`[Interface] Feat: bridge FScriptInterface in argument/return/property paths`

- [ ] **P2.4** TypeFinder 识别 C++ 侧 `TScriptInterface<IFoo>` 属性
  - `Bind_BlueprintType.cpp` 的 TypeFinder lambda（`BindUClassLookup` 所在段）补 `CastField<FInterfaceProperty>(Property)` 分支，返回 `FAngelscriptTypeUsage::FromClass(InterfaceClass)`，让 C++ 定义的 `UPROPERTY() TScriptInterface<IFoo>` 自动映射到 AS 接口类型
  - 确保脚本侧能读写这种属性
- [ ] **P2.4** 📦 Git 提交：`[Interface] Feat: TypeFinder recognizes FInterfaceProperty`

- [ ] **P2.5** 脚本侧 `TScriptInterface<UIFoo>` 语法糖（预处理器）
  - 决定是保持 "脚本里直接写 `UIFoo Ref`（Phase 2.2 已让它走 FInterfaceProperty）"还是"显式允许 `TScriptInterface<UIFoo> Ref`"
  - 本计划选**两者都支持**：`UIFoo Ref` 与 `TScriptInterface<UIFoo> Ref` 产生完全相同的 FInterfaceProperty；预处理器把后者在 chunk 分析阶段替换成前者（与现有 `TSubclassOf<T>` 语法糖类似处理方式，参考 `AngelscriptPreprocessor.cpp` 的类型替换段）
  - 参考预处理器现有 `TMap/TArray/TSubclassOf/TSoftObjectPtr` 等泛型类型处理的写法，新增一条 `TScriptInterface` 规则
- [ ] **P2.5** 📦 Git 提交：`[Interface] Feat: preprocessor TScriptInterface<T> alias to T for interface types`

- [x] **P2.6** 扩展 `Shared/AngelscriptNativeInterfaceTestTypes.h/cpp`（已在 Phase 2 结束时提前实现）
  - 现有 fixture 只覆盖 C++ 实现类 `ATestNativeParentInterfaceActor`，但它是**单继承**（只实现一个接口），`PointerOffset` 通常为 0，测不出双指针偏移
  - 新增 `UAngelscriptNativeSecondaryInterface`（2 方法 `GetSecondaryValue` / `SetSecondaryLabel`）+ `ATestNativeMultiInterfaceActor` 同时实现 Parent + Secondary，让 Secondary 接口 `PointerOffset` 非零
  - 带 `UPROPERTY() TScriptInterface<…>` 字段的 fixture 类推迟到 Phase 3 真正开始时补（需要与 FInterfaceProperty 支持同步落地）
- [x] **P2.6** 📦 Git 提交：`[Test/Interface] Feat: add multi-interface native fixture for pointer offset coverage`（commit `7cb4e4d`）

- [ ] **P2.7** 新增 `AngelscriptInterfacePropertyTests.cpp` 5 个用例
  - `InterfaceProperty.GetSet` — 脚本读写 `UPROPERTY() TScriptInterface<UIFoo>`，设置实现类对象后再读出一致
  - `InterfaceProperty.SetInvalid` — 赋值未实现接口的对象时 Setter 安全返回，不崩溃
  - `InterfaceProperty.Null` — 空引用读写
  - `InterfaceProperty.CallThrough` — 通过属性取到接口引用后调用方法
  - `InterfaceProperty.CppSideProperty` — C++ 类上的 `TScriptInterface<IFoo>` 属性在脚本中可读写
- [ ] **P2.7** 📦 Git 提交：`[Test/Interface] Feat: add TScriptInterface property tests`

- [ ] **P2.8** 新增 `AngelscriptInterfaceArgumentTests.cpp` 3 个用例
  - `InterfaceArg.PassThrough` — UFUNCTION 参数为 `TScriptInterface<UIFoo>` 时脚本↔C++ 互传正确
  - `InterfaceArg.Return` — UFUNCTION 返回 `TScriptInterface<UIFoo>` 时调用者拿到正确桥接对象
  - `InterfaceArg.NullPass` — 空 TScriptInterface 传参和返回不崩溃
- [ ] **P2.8** 📦 Git 提交：`[Test/Interface] Feat: add TScriptInterface argument/return tests`

### Phase 3：C++ 原生实现类的接口指针偏移修复

> 目标：脚本中 `Cast<UMyInterface>(NativeActor)` 以及后续接口方法调用时，`this` 指针与 `FScriptInterface::InterfacePointer` 按 `UObject::GetInterfaceAddress` 正确偏移。

**Phase 2 的实际结论**（通过 MCP `knot` + UE 源码核对得出）：

1. AS 侧接口都是以 UObject 引用形式注册（`RegisterObjectType ... asOBJ_REF | asOBJ_NOCOUNT | asOBJ_IMPLICIT_HANDLE`），`opCast` 写入 `OutAddress` 的必须是 `UObject*` 而不是偏移后的接口指针 — 否则 AS 会把偏移指针当 `UObject*` 处理，后续任何 UObject 解引用都会崩。所以 **`Bind_UObject.cpp:188-213` 的 opCast 接口分支保留原实现**，只加 helper 备用。
2. `CallInterfaceMethod` 走 `Object->FindFunction` + `InvokeReflectiveUFunctionFromGenericCall`，UE 反射层自行处理接口偏移，**无需**在 AS 层手工偏移 `this`。
3. 指针偏移的真正应用点是 `FScriptInterface::SetInterface` — 由 Phase 3 的 TScriptInterface 桥接使用；本 Phase 的 helper 作为基础设施先建好。

- [x] **P2.1 / P3.1** 新增双指针桥接助手
  - 在 `Binds/Bind_Helpers.h` 的 `FAngelscriptBindHelpers` 末尾新增 `GetInterfacePointerForCast(UObject*, UClass*)`：脚本实现类 `GetInterfaceAddress` 返回 `nullptr` 时兜底到 `Object`，C++ 原生实现类走 `Object->GetInterfaceAddress(InterfaceClass)`，`InterfaceClass` 非 `CLASS_Interface` 或未实现时返回 `nullptr`
  - 行为与 UE `FInterfaceProperty::SerializeItem` 的约定一致（`Object->GetInterfaceAddress(InterfaceClass)`，`ObjectPointer` 为空时 `SetInterface(nullptr)`）
  - Phase 3 的 4 个 `FInterfaceProperty` helper（Get/Set Argument/Property）将直接调用此函数填 `InterfacePointer`
- [x] **P2.1 / P3.1** 📦 Git 提交：`[Interface] Feat: add GetInterfacePointerForCast helper in Bind_Helpers`（commit `7c91abe`）

- [x] **P3.1-amend** opCast 接口分支保持原样（决策修正）
  - 原 Plan 设想"opCast 接口分支走 `GetInterfacePointerForCast`"会把 `*(UObject**)OutAddress` 写成接口偏移指针 — 这会破坏 AS 侧 UObject 句柄的 GC 语义和后续反射调用；不能这么做
  - 保留 `*(UObject**)OutAddress = Object;` 不变，UE 反射层自行处理接口分派
  - helper 留给 Phase 3 TScriptInterface 桥接路径使用
- [x] **P3.1-amend** 无代码 diff（decision-only）

- [x] **P3.3-early** 扩展 native fixture：`ATestNativeMultiInterfaceActor`
  - 现有 `ATestNativeParentInterfaceActor` 是单接口继承，`PointerOffset` 为 0，测不出双指针偏移场景
  - 新增 `UAngelscriptNativeSecondaryInterface`（2 方法）+ `ATestNativeMultiInterfaceActor` 同时实现 Parent + Secondary，强制 Secondary 接口 `PointerOffset` 非零
  - UHT 要求 `FString` 参数以 `const FString&` 传递，相应调整 `SetSecondaryLabel` 声明和 `_Implementation` 签名
- [x] **P3.3-early** 📦 Git 提交：`[Test/Interface] Feat: add multi-interface native fixture for pointer offset coverage`（commit `7cb4e4d`）

- [x] **P3.3** 新增 `AngelscriptInterfaceNativePointerOffsetTests.cpp` 2 个用例
  - `NativePointerOffset.MultiInterfaceCast` — 脚本 `Cast<UAngelscriptNativeParentInterface>` + `Cast<UAngelscriptNativeSecondaryInterface>` 对同一 C++ 多接口实现类都成功；分别通过两条接口引用调方法后各自更新到不同的 C++ 成员字段（`NativeMarker` vs `SecondaryLabel`），证明接口方法分派互不串扰
  - `NativePointerOffset.ScriptClassStillZeroOffset` — 脚本实现接口的类 `PointerOffset == 0`，Cast + 方法分派行为与 Phase 2 前完全一致（回归保护，确保 helper 未破坏快路径）
- [x] **P3.3** 📦 Git 提交：`[Test/Interface] Feat: native interface pointer offset regression tests`（commit `0114f67`，32/32 接口测试全通过）

### Phase 4：接口方法的 `BlueprintNativeEvent` / `BlueprintImplementableEvent` 语义

> 目标：脚本接口方法能标 `UFUNCTION(BlueprintNativeEvent)` / `UFUNCTION(BlueprintImplementableEvent)`，类生成 UFunction 存根带正确 flags，C++ `Execute_XXX` 调用能正确分发到脚本 override 或 C++ `_Implementation`。

- [ ] **P4.1** 预处理器保留接口块 UFUNCTION 修饰符
  - `Preprocessor/AngelscriptPreprocessor.cpp` 的接口 chunk 解析目前跳过 `UFUNCTION()`；改为：把 `UFUNCTION(...)` 的修饰符字符串和解析结果挂到 `FInterfaceMethodDeclaration`（`AngelscriptPreprocessor.h`）的新字段上，例如 `FString UFunctionSpecifierText` + `EInterfaceMethodFlags Flags`（组合位：`BlueprintNativeEvent`、`BlueprintImplementableEvent`、`BlueprintPure`、`BlueprintCallable`）
  - 接口块擦除行为不变（AS 编译器仍看不到 interface 块），但修饰符信息被保留给类生成阶段使用
- [ ] **P4.1** 📦 Git 提交：`[Interface] Feat: preprocessor retains interface UFUNCTION specifiers`

- [ ] **P4.2** 类生成按修饰符设置 UFunction flags
  - `AngelscriptClassGenerator.cpp` 生成接口 UFunction 存根时（Phase 1.5 已统一成 `GenerateInterfaceUFunctionStub`），按 `EInterfaceMethodFlags` 设置：
    - `BlueprintNativeEvent` → `FUNC_Net | FUNC_BlueprintEvent | FUNC_Native`（对齐 UHT 生成的 `Execute_XXX` 调用路径）
    - `BlueprintImplementableEvent` → `FUNC_BlueprintEvent`（无 `FUNC_Native`）
    - `BlueprintPure` → `FUNC_BlueprintPure`
    - `BlueprintCallable`（接口默认语义）→ `FUNC_BlueprintCallable`
  - UFunction 的 `FuncPtr` 对 `BlueprintNativeEvent` 要给一个默认桩（现有 `CallInterfaceMethod` 已具备，让它成为 `_Implementation` 的 fallback 即可）
- [ ] **P4.2** 📦 Git 提交：`[Interface] Feat: interface UFunction flags honor UFUNCTION specifiers`

- [ ] **P4.3** 扩展 fixture 和脚本示例
  - `Shared/AngelscriptNativeInterfaceTestTypes.h` 已有 `UFUNCTION(BlueprintCallable, BlueprintNativeEvent)`，Phase 4 的关键是证明"脚本类实现 C++ `BlueprintNativeEvent` 接口方法，C++ 侧 `IFoo::Execute_Method(ScriptActor)` 能命中脚本实现"以及"纯脚本声明的 `BlueprintNativeEvent` 接口方法也能分发"
  - 新增 `Script/Examples/Extended/Example_InterfaceBlueprintEvent.as` 示例脚本（展示接口方法带修饰符、脚本类 override）
- [ ] **P4.3** 📦 Git 提交：`[Interface] Feat: BlueprintNativeEvent script example and fixture`

- [ ] **P4.4** 新增 `AngelscriptInterfaceBlueprintEventTests.cpp` 4 个用例
  - `BlueprintEvent.ScriptOverridesNativeEvent` — C++ 接口方法标 `BlueprintNativeEvent`，脚本类提供 override，C++ `Execute_Method(ScriptActor)` 命中脚本实现
  - `BlueprintEvent.NativeImplementationFallback` — 脚本类未 override 时，`Execute_Method` 命中 C++ `_Implementation`
  - `BlueprintEvent.ScriptDeclaredNativeEvent` — 脚本声明的 `UFUNCTION(BlueprintNativeEvent)` 接口方法也能分发
  - `BlueprintEvent.SpecifierFlagsApplied` — 校验 UFunction 的 FlagsFuncFlags 精确等于预期（`FUNC_BlueprintEvent`、`FUNC_Native` 等）
- [ ] **P4.4** 📦 Git 提交：`[Test/Interface] Feat: BlueprintNativeEvent interface dispatch tests`

### Phase 5：`Obj.Implements<T>()` 泛型查询

> 目标：脚本能写 `Obj.Implements<UIFoo>()`，运行时等价于 `Obj.ImplementsInterface(UIFoo::StaticClass())`。

- [ ] **P5.1** 评估 AS 模板方法注册能力，选择实现路径
  - 现有 `Cast<T>()` 本质上是 AS 的 `opCast` 机制 + 引擎侧的类型查询，参考其模式（`Bind_UObject.cpp` opCast）与预处理器（是否存在模板替换 — 看 `AngelscriptPreprocessor.cpp`）
  - 若 AS 模板函数可注册（参考 `Plan_FunctionTemplate.md` 的进展），优先走模板路径；否则走预处理器语法糖：`Obj.Implements<UIFoo>()` → `Obj.ImplementsInterface(UIFoo::StaticClass())`
  - 本 P5.1 输出：一句结论 + 走哪条路径的代码骨架（保留在本计划 checklist 下方的 `实现路径` 子项）
- [ ] **P5.1** 📦 Git 提交：`[Interface] Docs: document Implements<T>() implementation path`

- [ ] **P5.2** 实现 `Obj.Implements<T>()` 语法
  - 按 P5.1 的决策选走模板注册或预处理器替换
  - 支持 T 为脚本定义接口（`UIFoo`）和 C++ 接口（`UAngelscriptNativeParentInterface`）
  - 对 T 非接口类型（比如 `AActor`）给出编译期诊断："`Implements<T>` expects T to be an interface type"
  - 保留现有 `Obj.ImplementsInterface(UClass)` 完全不变
- [ ] **P5.2** 📦 Git 提交：`[Interface] Feat: Obj.Implements<T>() generic interface query`

- [ ] **P5.3** 新增 `AngelscriptInterfaceImplementsGenericTests.cpp` 4 个用例
  - `ImplementsGeneric.ScriptInterfaceTrue` — 脚本接口 `Implements<UIFoo>()` 返回 true
  - `ImplementsGeneric.CppInterfaceTrue` — C++ 接口 `Implements<UAngelscriptNativeParentInterface>()` 返回 true
  - `ImplementsGeneric.NotImplementedFalse` — 未实现的接口返回 false
  - `ImplementsGeneric.NonInterfaceTypeDiagnostic` — `Implements<AActor>()` 编译期给出诊断（非接口类型）
- [ ] **P5.3** 📦 Git 提交：`[Test/Interface] Feat: Implements<T> generic query tests`

### Phase 6：测试回归与文档同步

> 目标：全量接口测试回归、知识文档更新、示例脚本刷新、归档前的最终检查。

- [ ] **P6.1** 全量运行接口测试集并检查覆盖
  - 运行 `Tools\RunAutomationTests.ps1`（或 `Tools\RunTestSuite.ps1 -Group Interface` 等价入口）跑 `Angelscript.TestModule.Interface.*`、`Angelscript.TestModule.Preprocessor.Interface.*`、`Angelscript.TestModule.Compiler.Interface.*`
  - 确认现有 36+ 测试零回归、新增 ≥15 个测试全部通过
  - 若有失败，回到对应 Phase 修复后再回归
- [ ] **P6.1** 📦 Git 提交：`[Test/Interface] Test: full interface suite passes with parity upgrades`

- [ ] **P6.2** 更新 `Documents/Knowledges/InterfaceBinding.md`
  - 在"当前支持范围"新增两个小节："TScriptInterface<I> 属性与参数桥接"（Phase 2）、"接口方法事件语义（BlueprintNativeEvent/BlueprintImplementableEvent）"（Phase 4）
  - "已知限制"表格删除：`FInterfaceProperty` 未参与（已修）、方法签名校验仅按函数名（已修）、接口方法无法使用 UFUNCTION 修饰符（已修）
  - "已知限制"保留并说明：接口块不进入 AS 编译器（fork 结构性分叉点，不修）、AS 语言级 interface 不支持（同上）
  - "架构决策记录"新增：零新增 ThirdParty 修改、保持仅 U 前缀、不做 Execute_ 语法糖
  - "测试覆盖"数字更新到最新
- [ ] **P6.2** 📦 Git 提交：`[Docs] Update: InterfaceBinding knowledge doc for parity upgrades`

- [ ] **P6.3** 更新 `Documents/Plans/Plan_InterfaceBinding.md`
  - 顶部加一行状态：`Phase 4/5（FInterfaceProperty、签名校验）已由 Plan_InterfaceParityWithCpp.md 承接并关闭`
  - 不迁移或删除 Plan_InterfaceBinding.md 本体（它承载了完整设计思路），只标状态，避免后续读者误以为那份 Plan 还在执行
- [ ] **P6.3** 📦 Git 提交：`[Docs] Chore: mark Plan_InterfaceBinding phases 4/5 as superseded`

- [ ] **P6.4** 更新示例脚本 `Script/Examples/Extended/Example_ScriptInterface.as`
  - 在末尾增加一个小节："使用 TScriptInterface<UIFoo> 属性存储接口引用"
  - 展示 `Obj.Implements<UIFoo>()` 泛型查询
  - 保持示例可运行（与现有脚本示例一致的风格）
- [ ] **P6.4** 📦 Git 提交：`[Script] Docs: extend Example_ScriptInterface with TScriptInterface and Implements<T>`

- [ ] **P6.5** 归档准备
  - 本计划完成后在文档顶部补齐"归档状态""归档日期""完成判断""结果摘要"四项（按 `Documents/Plans/Plan.md` 归档规则）
  - 移动到 `Documents/Plans/Archives/`，同步更新 `Archives/README.md`、`Plan_OpportunityIndex.md`、`Plan_StatusPriorityRoadmap.md`
- [ ] **P6.5** 📦 Git 提交：`[Docs] Chore: archive Plan_InterfaceParityWithCpp after closure`

## 验收标准

1. **签名校验**：接口方法参数数量/类型/返回值/const 不匹配时 `FinalizeClass` 阶段报错且日志可读；`Angelscript.TestModule.Interface.Signature.*` 5 个用例全通过。
2. **TScriptInterface 桥接**：脚本 `UPROPERTY() TScriptInterface<UIFoo>` 可读可写；UFUNCTION 参数/返回值为 `TScriptInterface<UIFoo>` 时跨反射边界正确传递；`Interface.Property.*` 5 + `Interface.Argument.*` 3 用例全通过。
3. **C++ 原生实现类偏移**：多接口继承场景 Cast 后调方法、写入 TScriptInterface 后读取均拿到正确偏移指针；`Interface.NativePointerOffset.*` 3 用例全通过。
4. **BlueprintNativeEvent 事件语义**：脚本声明与实现 `BlueprintNativeEvent` 接口方法分发行为与 C++ 一致；`Interface.BlueprintEvent.*` 4 用例全通过。
5. **`Obj.Implements<T>()` 泛型**：脚本接口与 C++ 接口统一可查；`Interface.ImplementsGeneric.*` 4 用例全通过。
6. **无回归**：现有 36+ 接口测试零失败。
7. **ThirdParty 无新增修改**：`git diff Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/` 相对于本 Plan 开始的基线无任何改动。
8. **文档同步**：`Documents/Knowledges/InterfaceBinding.md` 能力矩阵反映 Phase 1-5 的结果；`Plan_InterfaceBinding.md` 标注承接关系；示例脚本增加 TScriptInterface 与 `Implements<T>` 用法。

## 风险与已知行为变化

### 风险

1. **签名升级的降级路径可能被遗忘**：若 Phase 1 的降级分支（`ParamTypes.Num() == 0` 时跳过签名对比）在 Phase 4 生成 FProperty 链之后不再触发，既有脚本可能突然暴露一些签名微妙不匹配
   - **缓解**：P1.4 降级路径保留，增加单测覆盖"旧存根无 FProperty 链"场景；Phase 4 完成后评估是否安全删除降级路径，若不安全则保留不动
2. **TScriptInterface 属性的 GC 语义**：`FScriptInterface` 持 `ObjectPointer` + `InterfacePointer`，GC 只扫 `ObjectPointer`；如果把 `InterfacePointer` 当 UObject 解引用会悬空
   - **缓解**：Phase 2.3 helper 统一通过 `UObject::GetInterfaceAddress` 计算，不缓存 `InterfacePointer`；读取只走 `GetObject()` + 再次 `GetInterfaceAddress`
3. **AS 模板方法注册能力不足导致 Phase 5 走预处理器语法糖**：预处理器替换对"复杂表达式链 Obj.GetX().Implements<UIFoo>()"识别成本更高
   - **缓解**：P5.1 先给结论和骨架，若走预处理器路径，仅支持"标识符/成员表达式.Implements<T>()"的基本形态，不支持复杂链式；P5.3 测试中显式声明支持边界

### 已知行为变化

1. **接口方法签名不匹配的现有脚本会在升级后报错**：现状允许同名签名不同的实现通过 FinalizeClass；Phase 1 完成后这类脚本会在编译期被拒绝
   - 影响：`Plugins/Angelscript/Source/AngelscriptTest/Interface/**` 需要抽样检查是否有测试依赖"名字相同签名不同"的隐式行为（目前审查看似无）；运行 `Interface.Signature.ExactMatch` 做兜底
2. **`UPROPERTY UIFoo Ref` 生成的 FProperty 类型由 `FObjectProperty` 变为 `FInterfaceProperty`**：对脚本内部使用无影响；对外部 C++ 反射枚举脚本类属性的代码（如 Details Panel、序列化）行为更符合 UE 惯例，但仍可能让依赖"接口属性是 FObjectProperty"的代码失效
   - 影响：审查 `AngelscriptEditor` 是否有此类假设（预期没有），若有则同步修正
3. **接口 UFunction 存根 flags 变化**：Phase 4 后 `BlueprintNativeEvent` 接口方法会带上 `FUNC_Native` 等 flags
   - 影响：原先以"flag 为 0"做接口方法识别的代码（若有）失效；审查 `AngelscriptClassGenerator.cpp` 的 FinalizeClass 校验段与 Dump/CSV 导出相关代码
4. **Full Reload 生成的接口 UFunction 从 minimal 变为带完整 FProperty 链**：`Dump/AngelscriptStateDump` 相关 CSV 表中接口函数签名列的值会变化
   - 影响：`Angelscript.TestModule.DumpRegression.*` 可能需要更新基线；Phase 6.1 回归中确认

## 依赖关系

```text
Phase 0（决策与索引）
  ↓
Phase 1（签名完整校验 + 存根 FProperty 升级）
  ↓
Phase 2（TScriptInterface 属性/参数桥接） ── 依赖 Phase 1 的存根 FProperty 链
  ↓
Phase 3（C++ 原生实现类指针偏移修复） ── 与 Phase 2 共享 GetInterfacePointerForCast helper
  ↓
Phase 4（BlueprintNativeEvent 事件语义） ── 依赖 Phase 1 的存根 FProperty 链与 Phase 2 的 FInterfaceProperty
  ↓
Phase 5（Implements<T> 泛型） ── 可与 Phase 4 并行，只依赖 Phase 1
  ↓
Phase 6（回归与文档） ── 依赖前置全部
```

## 参考资料

| 资源 | 用途 |
|------|------|
| `Documents/Plans/Plan_InterfaceBinding.md` | 完整接口设计文档（本计划的 Phase 4/5 承接） |
| `Documents/Plans/Plan_CppInterfaceBinding.md` | C++ UInterface 自动绑定前置（已完成） |
| `Documents/Knowledges/InterfaceBinding.md` | 接口能力知识文档（Phase 6 更新对象） |
| `Documents/Guides/AngelscriptForkStrategy.md` | ThirdParty 修改约定与 fork 分叉点说明 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:59-62` | `FInterfaceMethodSignature` 当前定义（Phase 1 扩展起点） |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp:56-98` | `CallInterfaceMethod` 泛型回调 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp:98-213` | `ImplementsInterface` 与 opCast 接口分支（Phase 3/5 改动点） |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp` | `FUObjectType` 属性/参数桥接（Phase 2 改动点） |
| `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptNativeInterfaceTestTypes.h` | C++ UInterface 测试 fixture（Phase 2/3 扩展） |
| `Reference/UnrealCSharp` | 横向参考（`FDynamicInterfaceGenerator`、`FInterfacePropertyDescriptor`） |
