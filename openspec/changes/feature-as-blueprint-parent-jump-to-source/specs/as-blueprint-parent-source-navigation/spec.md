# Spec — as-blueprint-parent-source-navigation

## ADDED Requirements

### Requirement: 蓝图父类为 Angelscript 类时可跳转到源码

当蓝图的父类是 Angelscript 脚本类（`UASClass`/`UASStruct`）时，蓝图编辑器 SHALL 提供一个可用的"打开父类源码"操作，点击后在配置的外部编辑器（VS Code）中打开该父类对应的 `.as` 文件，并定位到类定义所在行号。

#### Scenario: 点击打开 AS 父类源码

- **WHEN** 用户在父类为某 Angelscript 类的蓝图编辑器中触发"打开父类源码"操作
- **THEN** 系统解析该父类对应的 `.as` 源文件路径与行号，并通过 `code --goto "<path>:<line>"` 在 VS Code 中打开该位置

#### Scenario: 父类为 C++ 类时保持原有行为

- **WHEN** 用户在父类为原生 C++ 类的蓝图编辑器中触发"打开父类源码"操作
- **THEN** 系统保持引擎原有的跳转到 IDE 行为，不受本能力影响

#### Scenario: 父类无法解析为脚本源时不误导

- **WHEN** 蓝图父类是 Angelscript 类，但其源文件路径/行号无法解析
- **THEN** 系统不执行打开操作，并以可见方式（日志或提示）告知无法定位，而不是静默失败或打开错误位置

### Requirement: 操作可见性绑定父类类型

"打开 Angelscript 父类源码"操作的可见性/可用性 SHALL 取决于当前蓝图父类是否为 Angelscript 类，避免在非脚本父类场景产生冗余入口。

#### Scenario: AS 父类显示入口

- **WHEN** 当前蓝图的 `ParentClass` 是 `UASClass`/`UASStruct`
- **THEN** "打开 Angelscript 父类源码"操作可见且可用

#### Scenario: 非 AS 父类隐藏入口

- **WHEN** 当前蓝图的 `ParentClass` 不是 Angelscript 类
- **THEN** 本能力提供的入口不显示（C++ 父类继续走引擎自带按钮）

### Requirement: 导航逻辑可测试且不强制启动外部进程

源码导航解析逻辑 SHALL 提供测试接缝，使自动化测试能在不实际启动 VS Code 的前提下断言"AS 父类 → 正确的 path:line"。

#### Scenario: 测试断言解析结果

- **WHEN** 测试通过覆盖打开位置的接口触发对某 AS 父类的导航
- **THEN** 测试可获取并断言解析出的源文件路径与行号，无需真正拉起外部编辑器进程
