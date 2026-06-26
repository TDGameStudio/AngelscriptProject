# Spec — angelscript-plugin-dependencies

## ADDED Requirements

### Requirement: 插件不得依赖已弃用或已移除的 plugin

`Angelscript.uplugin` 的 `Plugins` 依赖列表 SHALL NOT 声明在当前引擎版本（UE 5.8）中已弃用或已移除的 plugin。对已并入引擎核心的功能（如 StructUtils），SHALL 通过 Build.cs 的 engine module 依赖获取，而非 plugin 依赖。

#### Scenario: 启动时无 StructUtils 弃用警告

- **WHEN** 在 UE 5.8 下加载 Angelscript 插件
- **THEN** 不出现 `StructUtils` plugin 已弃用/即将移除的警告

#### Scenario: FInstancedStruct 绑定仍可用

- **WHEN** 移除 `Angelscript.uplugin` 的 StructUtils plugin 依赖后构建
- **THEN** `AngelscriptRuntime` 经 Build.cs 的 `StructUtils` module 依赖仍能正常链接 `FInstancedStruct` 等类型，绑定行为无回归
