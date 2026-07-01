## ADDED Requirements

### Requirement: Coverage 测试覆盖以统一矩阵记录于 OpenSpec

AngelScript `AngelscriptTest/Coverage/` 的测试覆盖情况 SHALL 以统一矩阵形式记录在 OpenSpec 中，并以实际测试代码作为唯一权威来源；`Documents/Coverage/` 不再作为覆盖记录的事实来源。

#### Scenario: 矩阵以代码为权威来源

- **GIVEN** Coverage 目录下存在 `AngelscriptCoverage*Tests.cpp` 测试文件
- **WHEN** 记录某主题的覆盖状态
- **THEN** 状态以该文件实际存在的 `TEST_METHOD` 与 Automation 前缀为准
- **AND** 不依据历史规划文档的乐观/过时声明

#### Scenario: 覆盖状态区分三态

- **GIVEN** 一个 Coverage 主题
- **WHEN** 在矩阵中标注其状态
- **THEN** 必须落入 已覆盖(✅)、部分覆盖(🟡)、待覆盖(⬜) 或 fork 不支持/不适用(🚫) 之一
- **AND** fork 不支持项需说明替代写法或边界测试位置

#### Scenario: 矩阵格式统一

- **GIVEN** 任意分类下的覆盖条目
- **WHEN** 以表格呈现
- **THEN** 列结构统一为 `主题 | 测试文件 | 方法数 | 状态 | 备注`
- **AND** 全文使用同一套图例标记

#### Scenario: 矩阵按领域拆分并由主索引聚合

- **GIVEN** 覆盖记录跨多个 AS 类型与功能系统
- **WHEN** 组织矩阵文件
- **THEN** 明细矩阵 SHALL 按 AS 类型 / 功能 拆分到 `matrices/` 下的多个文件（每个文件对应一组测试文件），大型功能系统各自独立成文
- **AND** `coverage-matrix.md` 作为主索引，集中维护统一图例、列说明、领域索引与全局汇总
- **AND** 各领域矩阵的文件数与方法数小计相加 SHALL 与全局汇总一致

#### Scenario: 领域矩阵以场景为行单位并指导实现

- **GIVEN** 一个领域矩阵文件
- **WHEN** 记录该领域的覆盖
- **THEN** 矩阵的行单位 SHALL 是**具体可验证场景**（能力/写法），而非仅列出测试文件
- **AND** 每个 ✅ 场景行 SHALL 注明断言该场景的 `TEST_METHOD`（跨文件时带 `文件::方法`）
- **AND** 尚未覆盖的场景 SHALL 以 ⬜ 行显式列出，作为待实现工作项
- **AND** fork 不支持的写法 SHALL 以 🚫 行记录其负向边界测试位置
