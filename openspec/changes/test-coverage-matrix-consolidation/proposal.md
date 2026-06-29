## Why

`Documents/Coverage/` 累积了 80 个零散的覆盖文档（计划、进度、报告、"任务完成"庆祝文等），状态列严重过时：`Coverage_MasterIndex.md` 仍声称整体完成度约 12%、物理/输入/UI 等"极高优先级"主题为 0%，而实际上 `Plugins/Angelscript/Source/AngelscriptTest/Coverage/` 下已落地 **89 个测试文件、90 个 Automation 主题、约 980 个 `TEST_METHOD`**，物理、增强输入、触摸、UI 动画、网络等都早已实现。文档与代码脱节，无法作为可信记录。

按照项目"OpenSpec = 记录"的约定，`Documents/Coverage/` 计划删除，Coverage 测试覆盖的记录改由本 OpenSpec change 统一承载。本 change 以**实际测试代码为唯一权威来源**，用统一矩阵格式重建覆盖记录。

本 change 定位为"承前启后"：**承前**＝把已完成的覆盖工作以统一矩阵记录下来；**启后**＝把未完成项与文档退役整理成可执行的后续计划。

- （承前）新增覆盖矩阵记录：`coverage-matrix.md` 作**主索引**（统一图例、列说明、领域索引、全局汇总），明细按 **AS 类型 / 功能** 拆分到 `matrices/` 下 **18 个领域矩阵**（如 `01-basic-types.md`、`03-containers.md`、`06-ustruct.md`、物理/输入/Widget/网络等大型功能系统各自独立成文）。每个领域矩阵对应一组测试文件，格式全程统一；功能系统矩阵附逐 `TEST_METHOD` 清单。
- （承前）新增 `coverage-gaps.md`：记录真实待覆盖/待增强项、fork 明确不支持/不适用的边界项，以及对历史文档"伪缺口"的纠偏（经对照代码审计，GC 循环引用、动态材质参数等实际已覆盖）。
- （启后）`tasks.md` §4–§6 安排后续工作：文档退役 cutover（先把 ~30 个测试 `.cpp` 头注释与 2 个 skill 文档的 `Documents/Coverage/` 引用改指本记录，再删除该目录）、若干低/中优先级缺口补充、以及矩阵维护约定。
- 确立 OpenSpec 为 Coverage 覆盖记录的唯一事实来源（Single Source of Truth），替代 `Documents/Coverage/` 下的散乱文档。
- 已执行文档退役 cutover：38 个测试 `.cpp` 的头注释引用与 2 个 skill 文档已改指本记录，随后删除 `Documents/Coverage/`（80 个文件）。改动仅限注释字符串，未触碰任何测试逻辑或运行时代码。

## Capabilities

### New Capabilities

- `as-test-coverage-matrix`: 规定 AngelScript Coverage 测试覆盖以统一矩阵形式记录于 OpenSpec，矩阵以实际测试代码为权威来源，并区分"已覆盖 / 待覆盖 / fork 不支持"三态。

### Modified Capabilities

- None.

## Impact

- 新增（本 change 目录内）：
  - `openspec/changes/test-coverage-matrix-consolidation/coverage-matrix.md`（主索引）
  - `openspec/changes/test-coverage-matrix-consolidation/matrices/01-basic-types.md … 18-misc-systems.md`（18 个领域矩阵）
  - `openspec/changes/test-coverage-matrix-consolidation/coverage-gaps.md`
  - `openspec/changes/test-coverage-matrix-consolidation/specs/as-test-coverage-matrix/spec.md`
- 后续删除（不在本 change 内执行，仅声明意图）：`Documents/Coverage/` 整目录。
- 不触碰：`Plugins/Angelscript/Source/AngelscriptTest/Coverage/` 下任何 `.cpp`。
