# 当时整理的纠偏提示词

这些是会话里给用户的备用句子，不是本 change 的实施方案。实施方案是以后改 `config.yaml` + `openspec-work`。需要临时拧粒度时可以用。

## 先探索，先别建 change

```text
先 /opsx:explore，不要创建 change，不要改代码。
问题：<一句话>
请先读相关代码和现有 openspec/specs，然后给出：
1. 现状和根因/约束
2. 2–3 个方案，每个写取舍
3. 推荐方案，以及明确非目标
4. 这个改动该不该拆成多个 change
等我确认方向后再 propose。
```

## 加厚 propose

```text
/opsx:propose <change-name>
意图：<一句话>
范围内：<3–7 条可观察结果>
范围外：<明确不要碰的东西>
我最在意的失败场景：<1–3 条>
约束：只走 Tools\RunBuild.ps1 / RunTests.ps1 / RunTestSuite.ps1

质量要求：
- proposal 必须有 Why / What / Non-goals / Impact（点名模块和路径）
- 行为变化必须写 specs，每条 SHALL 至少一个 GWT scenario
- 有架构或兼容性决策就写 design.md，每条决策写 Why X not Y
- 不要写“实现该功能”这种任务
- 每个 task 必须包含：精确路径、对应哪条 requirement、TDD 或 Non-TDD、完成时的验证命令
- 按依赖排序：失败测试 → 最小实现 → 验证
- 一个 task 超出一次 session 就拆
写完后先停，让我 review，不要 apply。
```

## 只重写已有 tasks.md

```text
不要改代码。只重写 openspec/changes/<name>/tasks.md。
对照 proposal / specs / design：
1. 每个 task 能指回一条 requirement；对不上的删掉或标 Out of scope
2. 先文件地图，再编号
3. 禁止：Implement X / Add tests / Update docs / Handle edge cases
4. 每条写成：做什么 + 哪个文件 + 完成标准 + 验证命令
5. 新行为/bug/复杂逻辑：先失败测试 task，再实现 task
6. 调查日志不要塞进 checkbox
7. 若超过一个可独立发布的意图，先建议拆 change
写完给一张对照表：requirement → tasks。
```

## 大 change 一次只做一块

```text
/opsx:apply <name>
只做 tasks.md 的第 <N> 组。
不要做后面的组，不要顺手重构。
做完勾选，跑该组写明的验证命令，停下来等我看 diff。
如果实现推翻了 design/tasks，先改文档再继续。
```
