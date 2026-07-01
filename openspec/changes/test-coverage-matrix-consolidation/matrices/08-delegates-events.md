# 委托与事件覆盖矩阵

> **本矩阵是委托/事件测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 4 个测试文件的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork 不支持。
>
> - 测试文件：`Delegate`(13) / `MulticastDelegate`(11) / `DynamicDelegate`(12) / `Event`(16) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.<Delegate|MulticastDelegate|DynamicDelegate|Event>`
> - 图例见 `../coverage-matrix.md`；委托边界见 `../coverage-gaps.md §2.4`。

## 1. 单播委托（DelegateTests 13）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础声明/绑定/执行 | ✅ | `DelegateBasics` |
| 参数 / 参数类型 / 返回值 | ✅ | `DelegateParameters` `DelegateParameterTypes` `DelegateReturnValue` |
| ExecuteIfBound | ✅ | `DelegateExecuteIfBound` |
| 签名矩阵 | ✅ | `DelegateSignatureMatrix` |
| 对象与枚举返回值 | ✅ | `DelegateObjectAndEnumReturnValues` |
| 重新绑定 / 成员运行期清除 | ✅ | `DelegateRebinding` `DelegateMemberRuntimeClearBoundary` |
| 成员与参数反射 | ✅ | `DelegateMemberAndParameterReflection` |
| 脚本结构 UFUNCTION 参数 / 脚本结构参数 执行 | ✅ | `DelegateScriptStructUFunctionParameterExecutes` `DelegateScriptStructParameterExecutes` |
| Lambda 语法绑定不支持 | 🚫 | `DelegateLambdaSyntaxIsUnsupported` |

## 2. 多播委托（MulticastDelegateTests 11）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 基础 Add/Broadcast | ✅ | `MulticastBasics` |
| 多监听器 | ✅ | `MulticastMultipleListeners` |
| 句柄管理 / Clear / RemoveAll | ✅ | `MulticastHandleManagement` `MulticastClear` `MulticastRemoveAll` |
| 参数 / 参数类型矩阵 | ✅ | `MulticastParameters` `MulticastEventParameterTypeMatrix` |
| 混合 UFUNCTION 监听器 | ✅ | `MulticastMixedUFunctionListeners` |
| 按对象解绑移除目标监听器 | ✅ | `MulticastUnbindObjectRemovesTargetListeners` |
| 事件声明元数据 | ✅ | `MulticastEventDeclarationMetadata` |
| Lambda 语法不支持 | 🚫 | `MulticastLambdaSyntaxIsUnsupported` |

## 3. 动态委托（DynamicDelegateTests 12）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 动态委托基础 / 动态多播 | ✅ | `DynamicDelegateBasics` `DynamicMulticastDelegate` |
| 参数 / 复杂参数 / 返回值 | ✅ | `DynamicDelegateParameters` `DynamicDelegateComplexParameters` `DynamicDelegateReturnValue` |
| BlueprintAssignable/Callable 元数据 | ✅ | `DynamicDelegateBlueprintAssignableAndCallableMetadata` |
| 序列化往返 | ✅ | `DynamicDelegateSerializationRoundTrip` |
| Clear | ✅ | `DynamicDelegateClear` |
| struct 负载属性执行 / 声明单播运行期 / 声明元数据 | ✅ | `DynamicDelegateStructPayloadPropertyExecutes` `DynamicDelegateDeclaredSingleCastRuntime` `DynamicDelegateDeclarationMetadata` |
| 动态宏名不是脚本 API（对照） | 🚫 | `DynamicMacroNamesAreNotScriptAPIs` |

## 4. 事件（EventTests 16）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 绑定与触发 / 生命周期 / 解绑 | ✅ | `EventBindAndTrigger` `EventLifecycle` `EventUnbinding` |
| 声明元数据 / BlueprintEvent 元数据与执行 | ✅ | `EventDeclarationMetadata` `EventBlueprintEventMetadataAndExecution` |
| 多处理器 / 碰撞 / 链式 | ✅ | `EventMultipleHandlers` `EventCollision` `EventChaining` |
| 内建 Actor/组件实例 / Widget 事件实例 / Timer 事件 | ✅ | `EventBuiltInActorAndComponentInstances` `EventWidgetEventInstances` `EventTimer` |
| 自定义游戏事件 | ✅ | `EventCustomGameEvents` |
| RepNotify 触发状态变更 | ✅ | `EventRepNotifyExecutesStateChange` |
| 非脚本面向边界 | 🚫 | `EventNonScriptFacingBoundaries` |
| Lambda 语法不支持 | 🚫 | `EventLambdaSyntaxIsUnsupported` |

---

## 汇总

| 文件 | 方法 |
|------|------|
| Delegate | 13 |
| MulticastDelegate | 11 |
| DynamicDelegate | 12 |
| Event | 16 |
| **合计** | **52** |

**待实现（⬜）**：当前无硬缺口。Lambda 绑定、`BindStatic`、多播返回值是 fork 不适用项（`../coverage-gaps.md §2.4`），已由 `*LambdaSyntaxIsUnsupported` 等边界守住。
