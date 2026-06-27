# Remaining 54 Unimplemented Markers - Detailed List

**Date**: 2026-06-27

---

## Coverage_FloatProperty.md (14 markers)

### Replicated Properties (2)
- [ ] `Replicated` - 需要网络支持 (Haze fork 不支持)
- [ ] `ReplicatedUsing` - 需要网络支持 (Haze fork 不支持)

### meta= Specifiers (6)
- [ ] `meta=(ClampMin="0.0", ClampMax="1.0")` - 编辑器元数据回读
- [ ] `meta=(UIMin="0.0", UIMax="100.0")` - 编辑器元数据回读
- [ ] `meta=(Units="Degrees")` - 单位元数据
- [ ] `meta=(Units="Centimeters")` - 单位元数据

### Special Float Values (6)
- [ ] 特殊值字面量 (`Math::NaN` / `Math::Inf`)
- [ ] NaN 生成 (`Math::NaN` 或 `0.0f / 0.0f`)
- [ ] NaN 检测 (`Math::IsNaN(X)`)
- [ ] Inf 生成 (`Math::Inf` 或 `1.0f / 0.0f`)
- [ ] -Inf 生成 (`-Math::Inf`)
- [ ] Inf 检测 (`Math::IsFinite(X)`)

---

## Coverage_BoolProperty.md (5 markers)

### Replicated Properties (2)
- [ ] `Replicated` - 需要网络支持 (Haze fork 不支持)
- [ ] `ReplicatedUsing` - 需要网络支持 (Haze fork 不支持)

### meta= Specifiers (3)
- [ ] `meta=(InlineEditConditionToggle)` - 编辑器元数据回读
- [ ] `meta=(EditCondition="bOtherBool")` - 编辑条件元数据
- [ ] `meta=(DisplayName="Enable Feature")` - 显示名称元数据

---

## Coverage_StringProperty.md (3 markers)

### Replicated Properties (3)
- [ ] FString `Replicated` - 需要网络支持
- [ ] FName `Replicated` - 需要网络支持
- [ ] FText `Replicated` - 需要网络支持

---

## Coverage_Networking.md (10 markers)

### Core Networking Features (10)
- [ ] Property Replication - `Replicated`
- [ ] Property Replication with Callback - `ReplicatedUsing`
- [ ] Server RPC - `Server`, `Reliable`, `Unreliable`
- [ ] Client RPC - `Client`, `Reliable`, `Unreliable`
- [ ] Multicast RPC - `NetMulticast`
- [ ] RPC Validation - `WithValidation`
- [ ] Network Relevancy - `NetOwner`, `NetRelevancy`
- [ ] Replication Conditions - `ReplicationCondition`
- [ ] Network Role Check - `Role`, `RemoteRole`
- [ ] Network Authority - `HasAuthority()`

**Note**: Haze fork 明确不支持所有网络功能，这些应保持 ⬜

---

## Coverage_UClass.md (4 markers)

### Networking Features (4)
- [ ] Replicated 属性 - 网络属性复制
- [ ] ReplicatedUsing - 带回调的复制
- [ ] Server RPC - 服务器远程调用
- [ ] Client RPC - 客户端远程调用

---

## Coverage_OtherMacros.md (10 markers)

### Advanced Macro Features (10)
- [ ] `UINTERFACE` 声明
- [ ] `GENERATED_BODY()` 在接口中
- [ ] `UDELEGATE` 声明
- [ ] 自定义元数据宏
- [ ] `UPARAM` 参数修饰
- [ ] `UMETA` 枚举元数据
- [ ] `WITH_EDITOR` 条件编译
- [ ] `USTRUCT` 高级特性
- [ ] 反射宏组合使用
- [ ] 宏展开边界情况

---

## Coverage_Mixin.md (3 markers)

### Advanced Mixin Features (3)
- [ ] Mixin 多重继承冲突解决
- [ ] Mixin 虚函数覆盖
- [ ] Mixin 与 UPROPERTY 交互边界情况

---

## Coverage_Containers.md (2 markers)

### Edge Cases (2)
- [ ] `TArray<TArray<T>>` 深度嵌套
- [ ] 容器迭代器高级用法

---

## Coverage_NegativeTests.md (1 marker)

### Negative Testing (1)
- [ ] 错误处理边界情况全覆盖

---

## Coverage_UI_UMG.md (2 markers)

### Advanced UI Features (2)
- [ ] `SetFont(FSlateFontInfo)` - 字体设置
- [ ] `FSlateFontInfo` 结构体完整支持

---

## Summary by Category

| Category | Count | Status |
|----------|------:|--------|
| Networking (Replicated/RPC) | 17 | 🚫 Haze fork 不支持 |
| meta= Specifiers | 13 | ⬜ 需要编辑器测试 |
| Float Special Values | 6 | ⬜ 需要 Math API 测试 |
| Advanced Macros | 10 | ⬜ 需要专项实现 |
| Mixin Advanced | 3 | ⬜ 需要边界测试 |
| Container Edge Cases | 2 | ⬜ 需要嵌套测试 |
| UI/UMG Advanced | 2 | ⬜ 需要 UI 测试 |
| Negative Tests | 1 | ⬜ 需要错误测试 |

**Total**: 54 markers

---

## Implementation Priority (if needed)

### High Priority (19)
- Float Special Values (6) - Math API 相对容易添加
- meta= Specifiers (13) - 如果编辑器测试框架就绪

### Medium Priority (15)
- Advanced Macros (10) - 取决于宏系统扩展
- Mixin Advanced (3) - 取决于 Mixin 系统成熟度
- Container Edge Cases (2) - 相对独立的功能

### Low Priority / Not Planned (20)
- Networking (17) - Haze fork 架构决策，不支持
- UI/UMG Advanced (2) - 取决于 UI 集成需求
- Negative Tests (1) - 持续性工作

---

**Note**: 这些标记应保持 ⬜ 直到对应功能实际实现并有测试覆盖。
