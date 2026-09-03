# TOptional UClass 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TOptional/UClass`
- Bind 权威: `Bind_TOptional_Type.cpp` 的 `FAngelscriptOptionalType`
- 约定: 上级 `../Organization.md`

必须有 `UCLASS` / `UPROPERTY` 的正例。本目录只用 `NewObject` 宿主，**没有 `SpawnActor` 活引用**（TOptional 无 WorldStory 题材）。

---

## 1. 为什么 TOptional 能有 UPROPERTY

`FAngelscriptOptionalType` 注册了 GC schema：`EmitReferenceInfo` 生成 `UE::GC::EMemberType::Optional` 成员，内层 subtype 自己 emit 引用信息。所以 optional 属性参与垃圾回收，`TOptional<UObject>` 这类持有引用的形状是安全的。

`CanQueryPropertyType()` 返回 false，但 `RequiresProperty()` 也是 false —— 属性不需要强制存在即可解析。

## 2. 清单

| 文件 | 角色 |
|---|---|
| `TOptionalProperty.as` | UPROPERTY 六种元素形状；起始 unset、set 后保持、Reset 清空、每实例独立 |

## 3. 入口

| 入口 | 验证 |
|---|---|
| `OptionalPropertiesStartUnset` | 新实例上六个 optional 属性全部 unset |
| `OptionalPropertiesKeepSetState` | Set 之后六个属性都保持 set 且值正确 |
| `ResetOptionalPropertyClearsState` | Reset 清空属性，`Get` 返回 fallback 而不抛 |
| `OptionalPropertiesArePerInstance` | 两个实例的属性状态互不影响 |

## 4. 元素形状

`int` / `FString` / `FName` / `bool` / `FVector` / `UObject`，与 `../Function/` 的类型后缀六件套一致。

## 5. 不收

- 容器套容器属性（`TOptional<TArray<int>>` UPROPERTY）：非法，在 `../Negative/TOptionalOfArrayProperty`
- 能编译的纯函数入口：归 `../Function/`
