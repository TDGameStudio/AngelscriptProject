# UE 宏 / UENUM / UFUNCTION / UINTERFACE / 元说明符 覆盖矩阵

> **本矩阵是反射宏测试的设计规格("头")**（USTRUCT 除外，见 `06-ustruct.md`）：每行是一个**具体可验证场景**。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 拒绝边界。
>
> - 测试文件：`UEnum`(13) / `UFunction`(44) / `UInterface`(12) / `Macros`(19) / `MetaSpecifier`(13) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<UEnum|UFunction|UInterface|Macros|MetaSpecifier>`
> - 图例见 `../coverage-matrix.md`；接口边界见 `../coverage-gaps.md §2.3`。

## 1. UENUM（UEnumTests 13）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础声明 | ✅ | `UEnumBasicDeclaration` |
| 说明符 / meta / 位标志 meta | ✅ | `UEnumSpecifiers` `UEnumMeta` `UEnumMetaBitflags` |
| enum class 用法 / 反射查询 / 通用用法 | ✅ | `UEnumClassUsage` `UEnumReflectionQuery` `UEnumUsage` |
| switch / 转换 / 位标志运算 | ✅ | `UEnumSwitch` `UEnumConversion` `UEnumBitflags` |
| 在容器中 | ✅ | `UEnumInContainers` |
| Bitflags 说明符被拒 / 无效诊断 | 🚫 | `UEnumBitflagsSpecifierRejected` `UEnumInvalidDiagnostics` |

## 2. UFUNCTION（UFunctionTests 44）

### 2.1 说明符与元数据

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 说明符与元数据 / 参数元数据 | ✅ | `UFunctionSpecifiersAndMetadata` `UFunctionParameterMetadata` |
| UParam 显示名与 ref 矩阵 | ✅ | `UParamDisplayNameAndRefMatrix` |
| 说明符标志边界 | ✅ | `UFunctionSpecifierFlagEdges` |
| Editor/Exec/Authority 说明符组合 | ✅ | `EditorExecAndAuthoritySpecifierCombinations` |
| BlueprintCallable 抑制与说明符顺序矩阵 | ✅ | `BlueprintCallableSuppressionAndSpecifierOrderMatrix` |
| 访问修饰符函数标志矩阵 | ✅ | `AccessModifierFunctionFlagMatrix` |
| 属性访问器回调 UFUNCTION 矩阵 | ✅ | `PropertyAccessorCallbackUFunctionMatrix` |
| ThreadSafe 分发子类矩阵 | ✅ | `ThreadSafeDispatchSubclassMatrix` |
| WorldContext 元数据反射参数名 | ✅ | `WorldContextMetadataReflectsParameterName` |
| 高级函数元数据与运行期矩阵 | ✅ | `AdvancedFunctionMetadataAndRuntimeMatrix` |

### 2.2 分发与调用

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 函数分发子类形态矩阵 | ✅ | `FunctionDispatchSubclassShapeMatrix` |
| 基础成员与 const 反射调用 | ✅ | `BasicMemberAndConstReflectionCall` |
| 递归与虚重写分发 | ✅ | `RecursionAndVirtualOverrideDispatch` |
| 混合参数反射与运行期调用 | ✅ | `MixedParameterReflectionAndRuntimeCall` |

### 2.3 静态/全局函数

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 静态全局函数反射与运行期调用 | ✅ | `StaticGlobalFunctionReflectionAndRuntimeCall` |
| 静态 WorldContext 生成矩阵 | ✅ | `StaticWorldContextGenerationMatrix` |
| 静态全局复杂参数矩阵 | ✅ | `StaticGlobalComplexParameterMatrix` |
| 静态全局高级元数据与命名空间矩阵 | ✅ | `StaticGlobalAdvancedMetadataAndNamespaceMatrix` |

### 2.4 网络说明符

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 网络说明符标志矩阵 | ✅ | `NetworkSpecifierFlagMatrix` |
| 网络说明符可调用/权限/元数据矩阵 | ✅ | `NetworkSpecifierCallableAuthorityAndMetadataMatrix` |

### 2.5 BlueprintOverride / BlueprintEvent

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| Override BeginPlay/Tick 与 Super 执行 | ✅ | `BlueprintOverrideBeginPlayTickAndSuperExecute` |
| Override 原生 Actor 事件参数矩阵 | ✅ | `BlueprintOverrideNativeActorEventParameterMatrix` |
| Override 继承元数据 / out 参数与 Super / const Pure | ✅ | `BlueprintOverrideInheritanceMetadataMatrix` `BlueprintOverrideOutParameterAndSuperMatrix` `ConstBlueprintPureOverrideMatrix` |
| BlueprintEvent 反射与调用实现 | ✅ | `BlueprintEventReflectsAndInvokesImplementation` |
| BlueprintEvent Callable/Pure/out 参数矩阵 | ✅ | `BlueprintEventCallablePureAndOutParameterMatrix` |
| BlueprintEvent 默认参数与 ref 参数矩阵 | ✅ | `BlueprintEventDefaultArgumentsAndRefParameterMatrix` |
| BlueprintPure out-only 与 inout 运行期矩阵 | ✅ | `BlueprintPureOutOnlyAndInoutRuntimeMatrix` |

### 2.6 参数 / 返回值 / 类型反射

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 返回类型反射矩阵 | ✅ | `ReturnTypeReflectionMatrix` |
| 对象/类参数反射矩阵 | ✅ | `ObjectAndClassParameterReflectionMatrix` |
| 枚举参数/返回/容器矩阵 | ✅ | `EnumParameterReturnAndContainerMatrix` |
| handle 参数与返回反射矩阵 | ✅ | `HandleParameterAndReturnReflectionMatrix` |
| 委托参数反射与运行期矩阵 | ✅ | `DelegateParameterReflectionAndRuntimeMatrix` |
| 基础参数顺序与 out 布局矩阵 | ✅ | `PrimitiveParameterOrderAndOutLayoutMatrix` |
| 默认参数与 out 标志布局 / 类型转换矩阵 | ✅ | `DefaultArgumentsAndOutFlagLayout` `DefaultArgumentTypeConversionMatrix` |
| 引用方向标志与运行期矩阵 | ✅ | `ReferenceDirectionFlagAndRuntimeMatrix` |
| 返回与 out 参数排列矩阵 | ✅ | `ReturnAndOutParameterPermutationMatrix` |
| 容器参数与返回反射矩阵 | ✅ | `ContainerParameterAndReturnReflectionMatrix` |
| 脚本结构参数方向与返回矩阵 | ✅ | `ScriptStructParameterDirectionAndReturnMatrix` |
| optional 返回反射矩阵 | ✅ | `OptionalReturnReflectionMatrix` |
| 不支持的 UFUNCTION 形态诊断（边界） | 🚫 | `UnsupportedUFunctionShapeDiagnostics` |

## 3. UINTERFACE（UInterfaceTests 12）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 原生接口引用成员与分发 | ✅ | `NativeInterfaceReferenceMemberAndDispatch` |
| 原生接口多态引用与参数 | ✅ | `NativeInterfacePolymorphicReferencesAndParameters` |
| 单接口元数据与反射分发 | ✅ | `NativeSingleInterfaceMetadataAndReflectedDispatch` |
| 多接口元数据与独立分发 | ✅ | `NativeMultipleInterfaceMetadataAndIndependentDispatch` |
| 脚本级 interface 关键字被拒 | 🚫 | `ScriptInterfaceKeywordRejected` `ScriptInterfaceMethodsRejected` |
| UINTERFACE 宏/说明符/Blueprintable/GeneratedBody 在脚本中被拒 | 🚫 | `UInterfaceMacroDeclarationRejected` `UInterfaceSpecifierDeclarationRejected` `UInterfaceBlueprintableSpecifierRejected` `GeneratedBodyInsideInterfaceRejected` |
| `TScriptInterface<I>` / 其数组被拒 | 🚫 | `TScriptInterfaceTypeRejected` `TScriptInterfaceArrayRejected` |

## 4. 综合宏（MacrosTests 19）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| UDelegate 宏与脚本委托反射 | ✅ | `UDelegateMacroDeclarationRejected` `ScriptDelegateReflectsUDelegateFunction` |
| 自定义元数据键往返 / 编辑器条件激活分支 | ✅ | `CustomMetadataKeysRoundTrip` `EditorConditionActiveBranchReflects` |
| 反射宏组合 / 宏展开忽略注释字符串与失活分支 | ✅ | `ReflectionMacroCombination` `MacroExpansionIgnoresCommentsStringsAndInactiveBranches` |
| UEnum 高级声明/自定义元数据/位标志运行期 | ✅ | `UEnumAdvancedDeclaration` `UEnumCustomMetadataRoundTrip` `UEnumBitflagMetadataAndRuntimeOperators` |
| UFunction 说明符元数据与 const 反射 / 递归虚重写与 Super | ✅ | `UFunctionSpecifiersMetadataAndConstReflection` `UFunctionRecursiveVirtualOverrideAndSuperCall` |
| UStruct 高级用法 / UParam 修饰符 | ✅ | `UStructAdvancedUsage` `UParamModifiers` |
| BlueprintEvent 元数据与分发 / 默认实现 | ✅ | `BlueprintEventMetadataAndDispatch` `BlueprintEventDefaultImplementations` |
| 接口/GeneratedBody/ScriptInterface/WithEditor 宏在脚本中被拒 | 🚫 | `UInterfaceMacroDeclarationRejected` `GeneratedBodyInsideInterfaceRejected` `ScriptInterfaceDeclarationBoundariesRejected` `WithEditorMacroNameRejected` `DynamicMacroNamesAreNotScriptAPIs`(对照) |

## 5. 元说明符（MetaSpecifierTests 13）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| ClampMin/Max / UIMin/Max / Units | ✅ | `ClampMinMaxMeta` `UIMinMaxMeta` `UnitsMeta` |
| DisplayName / 属性呈现 meta | ✅ | `DisplayNameMeta` `PropertyPresentationMeta` |
| EditCondition / Inline 切换 | ✅ | `EditConditionMeta` `InlineEditConditionToggleMeta` |
| float 编辑器 meta 往返 | ✅ | `FloatEditorMetaSpecifierRoundTrip` |
| UClass 显示与 BP meta | ✅ | `UClassDisplayAndBlueprintMeta` |
| UFunction 基础说明符与标志 / 显示与参数 meta / WorldContext 与 Pin meta / 递归 | ✅ | `UFunctionBasicSpecifiersAndFlags` `UFunctionDisplayAndParameterMeta` `UFunctionWorldContextAndPinMeta` `UFunctionRecursion` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| UEnum | 13 |
| UFunction | 44 |
| UInterface | 12 |
| Macros | 19 |
| MetaSpecifier | 13 |
| **合计** | **101** |

**待实现（⬜）**：当前无硬缺口。脚本级 interface / `TScriptInterface` 是 fork 明确不支持项，已由 UInterface/Macros 的 `*Rejected` 边界守住（`../coverage-gaps.md §2.3`），fork 若放开再迁移为 ⬜。
