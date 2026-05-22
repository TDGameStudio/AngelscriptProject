# AngelScript 示例脚本

本目录包含 AngelScript 插件的示例脚本集合，按主题分为三个类别。

**使用方式**：将需要的 `.as` 文件复制到你的项目 `Script/` 目录下即可使用。

---

## Core — 核心语言与 UE 基础（20 个）

基础 AngelScript 语法和 Unreal Engine 常用 gameplay 模式：

| 示例 | 展示内容 |
|------|---------|
| `Example_Actor.as` | Actor 类定义、UPROPERTY、UFUNCTION、BeginPlay 重写、BlueprintEvent |
| `Example_Array.as` | TArray 容器操作：Add、Remove、Contains、FindIndex、range-for |
| `Example_Map.as` | TMap 容器操作：Add、Find、FindOrAdd、range-for、引用修改 |
| `Example_Struct.as` | 自定义 Struct 定义、UPROPERTY 反射、C++ Struct 复用 |
| `Example_Enum.as` | 枚举定义、switch 匹配、int 到 enum 转换 |
| `Example_Delegates.as` | delegate / event 声明、BindUFunction、Broadcast、Execute |
| `Example_Functions.as` | 全局 UFUNCTION、Category、BlueprintEvent、输出参数 (&out) |
| `Example_FunctionSpecifiers.as` | BlueprintPure / BlueprintEvent / BlueprintOverride / CallInEditor / NotBlueprintCallable |
| `Example_PropertySpecifiers.as` | NotEditable / EditConst / BlueprintReadOnly / MakeEditWidget / EditCondition / ClampMin-Max |
| `Example_AccessSpecifiers.as` | 自定义 access 修饰符、readonly / editdefaults / inherited 控制 |
| `Example_FormatString.as` | f-string 格式化：表达式插值、精度控制、对齐、枚举格式化 |
| `Example_Math.as` | Math:: 命名空间：Abs / Min / Max / Clamp / Sin / RandRange |
| `Example_MixinMethods.as` | mixin 关键字：为现有类型添加扩展方法 |
| `Example_Timers.as` | System::SetTimer / PauseTimerHandle / ClearAndInvalidateTimerHandle |
| `Example_Overlaps.as` | Actor 重叠检测 + Component 事件绑定 (OnComponentBeginOverlap) |
| `Example_MovingObject.as` | 可移动 Actor：Tick 驱动移动、default 关键字、网络复制标记 |
| `Example_ConstructionScript.as` | ConstructionScript：动态创建组件、编辑器时计算派生属性 |
| `Example_CharacterInput.as` | ACharacter 输入处理：按键事件、轴输入 |
| `Example_BehaviorTreeNodes.as` | AI 行为树节点：BTDecorator / BTService / BTTask 脚本化 |
| `Example_Widget_UMG.as` | UMG Widget 基类：BindWidget、Tick 更新、添加到 Viewport |

## EnhancedInput — UE5 增强输入（2 个）

UE5 Enhanced Input System 集成示例：

| 示例 | 展示内容 |
|------|---------|
| `Example_EI_Component.as` | 通过 UEnhancedInputComponent 绑定 InputAction |
| `Example_EI_PlayerController.as` | 通过 PlayerController 设置 InputMappingContext 和绑定 |

> **前置条件**：需要在编辑器中创建 `UInputAction` 和 `UInputMappingContext` 资产并赋值给对应属性。

## Extended — 本项目扩展能力（5 个）

展示当前插件独有或正在完善的能力：

| 示例 | 展示内容 |
|------|---------|
| `Example_SubsystemLifecycle.as` | Engine / LocalPlayer Subsystem 生命周期 |
| `Example_InterfaceDispatch.as` | UInterface 声明、实现和多态调用 |
| `Example_BlueprintSubclass.as` | 脚本类作为 Blueprint 基类、继承和事件重写 |
| `Example_NetworkReplication.as` | Replicated 属性、RepNotify、Server/Client/Multicast RPC 声明 |
| `Example_ConsoleWorkflow.as` | 命名空间全局变量、跨模块状态共享 |

> **注意**：Extended 示例中的部分能力（如 WorldSubsystem、完整 Network Push Model）仍在完善中，示例仅展示当前已稳定的声明模式。

---

## 与内联测试的关系

插件测试模块 `Plugins/Angelscript/Source/AngelscriptTest/Examples/` 中已有对应的 C++ 编译测试（`AngelscriptScriptExample*Test.cpp`），它们通过内联字符串验证示例代码的编译正确性。本目录下的 `.as` 文件是这些示例的**正式资产版本**，可作为用户参考和项目级测试使用。

<!-- Phase 4 sweep note: `obj.PascalCase` matches such as Fixture.Value, MoveInput.X/Y, ExampleStruct fields, MainText.Text, and named arguments such as Duration=5.0 are approved raw-field, struct-field, or call-argument usages, not property-accessor leftovers. -->

## 排除项

以下 Hazelight 基线中的示例类别当前不包含在本目录中：

- **GASExamples**（Gameplay Ability System）— GAS 支持已拆到可选 `Plugins/AngelscriptGAS/` 插件，示例会随 Aura/GAS 工作流成熟后单独补齐
- **EditorExamples**（编辑器扩展脚本）— 暂不作为必做范围
