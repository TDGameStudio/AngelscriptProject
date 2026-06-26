# Spec — as-function-table-incremental-generation

## ADDED Requirements

### Requirement: 无关代码改动不应触发函数表分片全量重编

`AngelscriptUHTTool` 生成的 `AS_FunctionTable_*` 分片 SHALL 仅在其对应反射输入实际变化时重新编译。改动与绑定无关的源码（不含 `UFUNCTION` 反射变化的 `.cpp`）SHALL NOT 触发全部分片重编。

#### Scenario: 仅改无关 .cpp 时不全量重编

- **WHEN** 开发者修改一个不含反射变化的业务 `.cpp` 并增量构建
- **THEN** `AS_FunctionTable_*` 分片不因此全量重编（理想情况为零分片重编）

#### Scenario: 反射变化时正确重生成

- **WHEN** 某模块的 `UFUNCTION` 反射定义发生变化
- **THEN** 受影响的对应分片重新生成并重编，且生成产物对相同反射输入保持确定性（字节级稳定）

### Requirement: 生成产物在重构后保持等价

对函数表生成器的增量优化（如收窄 shard 注入的 include、加固增量护栏）SHALL NOT 改变生成产物的绑定语义。

#### Scenario: 优化前后产物等价

- **WHEN** 对 codegen 进行增量性能优化后重新生成
- **THEN** 生成的函数表绑定逻辑与优化前等价（仅 include 行或重编粒度变化），相关绑定测试全部通过
