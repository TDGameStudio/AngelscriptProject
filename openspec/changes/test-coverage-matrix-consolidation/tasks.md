# Tasks — test-coverage-matrix-consolidation

> 本 change "承前启后"：§1–§3 是**已完成的记录（承前）**；§4–§6 是**安排给之后补充的工作（启后）**，未勾选即为待办，可在后续会话继续执行。
> 验证命令统一只用：`Tools\RunTests.ps1`（按 Automation 前缀过滤）。

## 1. 扫描与梳理（已完成）

- [x] 1.1 扫描 `AngelscriptTest/Coverage/*.cpp`，提取每个文件的 Automation 前缀与 `TEST_METHOD` 数量
- [x] 1.2 对照 `Documents/Coverage/` 历史文档，识别过时/伪缺口声明

## 2. 撰写统一矩阵（已完成）

- [x] 2.1 撰写 `coverage-matrix.md`：按分类列出已实现覆盖（统一列结构与图例）
- [x] 2.2 撰写 `coverage-gaps.md`：待覆盖/待增强 + fork 不支持边界 + 历史误标纠偏
- [x] 2.3 撰写 `specs/as-test-coverage-matrix/spec.md`：确立 OpenSpec 为覆盖记录 SoT
- [x] 2.4 按 AS 类型/功能将矩阵拆分为 `matrices/` 下 18 个领域矩阵（UStruct/容器/类型/对象引用各独立，物理/输入/Widget/网络/定时器等功能系统各自成文）；`coverage-matrix.md` 收敛为主索引（图例/列说明/领域索引/全局汇总）。功能系统矩阵附逐 `TEST_METHOD` 清单。

## 3. 校验记录（已完成）

- [x] 3.1 校验矩阵汇总数字（89 文件 / 90 主题 / ~980 方法）与扫描结果一致
- [x] 3.2 审计推翻伪缺口（GC 循环引用、动态材质参数实际已覆盖），同步修正矩阵状态

---

## 4. 文档退役 cutover（已完成，先改指后删除）

> 目标：`Documents/Coverage/` 退役，引用统一改指向本 OpenSpec 记录，无悬空引用。

- [x] 4.1 将 38 个 Coverage 测试 `.cpp` 头注释中的 `Documents/Coverage/Coverage_*.md` 引用，统一改指 `OpenSpec: test-coverage-matrix-consolidation/coverage-matrix.md`
- [x] 4.2 更新 `.agents/skills/_angelscript-test-guide/SKILL.md` 与 `SKILL_ZH.md` 中对 `Documents/Coverage/` 的引用
- [x] 4.3 确认无其它文档引用后，删除 `Documents/Coverage/` 整目录（80 个文件）
- [x] 4.4 `git grep "Documents/Coverage"` 无残留（仅 openspec 记录内说明性提及）

## 5. 覆盖缺口补充（待办，低/中优先级，TDD）

> 详见 `coverage-gaps.md §1`。均非阻塞项；按需逐个执行，新增测试遵循 `_angelscript-test-guide`。

- [ ] 5.1 (G1) 扩充 `AngelscriptCoverageAnimInstanceTests.cpp`：把"可编译"查询升级为运行期行为断言（状态/变量驱动/通知），目标前缀 `Angelscript.TestModule.Coverage.Animation.AnimInstance`。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Animation.AnimInstance"`
- [ ] 5.2 (G2) 扩充 `AngelscriptCoverageSaveGameTests.cpp`：嵌套 struct / 数组字段 save→load 往返断言。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.SaveGame"`
- [ ] 5.3 (G3) 审计并按需补 `AngelscriptCoverageWeakReferenceTests.cpp`：`TArray<TWeakObjectPtr<T>>` 元素往返/失效。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.WeakReference"`
- [ ] 5.4 (G4) 审计 `TObjectPtr<T>` 作为显式 UPROPERTY 的声明/读写是否已隐含覆盖；缺则补 `AngelscriptCoverageHandlesTests.cpp`。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Handles"`

## 6. 维护约定（持续）

- [ ] 6.1 后续新增/删除 Coverage 测试文件时，先更新所属 `matrices/<领域>.md` 对应行，再回填 `coverage-matrix.md` 主索引的领域文件数/方法数与全局汇总
- [ ] 6.2 若 fork 后续绑定了当前不支持的 API（见 `coverage-gaps.md §2`），将对应行从 🚫 迁移为 ⬜ 并排期补测
- [ ] 6.3 单个领域矩阵若膨胀过大（如 `06-ustruct.md` 对应的 16k 行测试文件），可进一步拆分子文件并在主索引补行
