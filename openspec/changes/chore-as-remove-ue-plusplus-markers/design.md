## Context

产品口径已是 Unreal AngelScript 1.0.0：语言、内核和对象模型按 UE 维护，不是可替换的官方 AngelScript。`[UE++]` / `[UE--]` 仍出现在约 150+ 条注释里，并被 `AngelscriptForkStrategy.md` / `RT_ThirdPartyKernel.md` 写成硬规则。测试、Tools、共享 specs 都不依赖这些标记。

## Goals / Non-Goals

**Goals:**

- 成对去掉源码中的 `[UE++]` 与 `[UE--]`。
- 保留 `//[UE++]:` 后面的说明正文。
- 改掉现行文档里「必须加标记」的规则，禁止新增。

**Non-Goals:**

- 不改可执行逻辑、类型、ABI、构建脚本。
- 不重排 ThirdParty，不删「2.38 / APV2」等说明内容。
- 不改写 `Documents/Plans/` 或已有 / 归档 OpenSpec 正文。
- 不为注释-only 变更跑全量 Automation。

## Decisions

1. **剥标签，不删说明。** `//[UE++]: Foo` → `// Foo`。单独的 `//[UE++]` / `//[UE--]` 整行删除。围栏没有语义，正文还有阅读价值。
2. **范围含纯 UE 层。** ClassGenerator / Preprocessor / `AngelscriptEngine.cpp` 上的同类标记一并去掉；那些文件本来就不是 vendor overlay。
3. **历史文档不动。** 旧 Plan 和已完成 change 里的提及保持原样，避免伪造历史。
4. **吸收上游仍用 cherry-pick + 测试，不再靠围栏注释。** 选择性吸收策略不变，只换追踪手段。

## Risks / Trade-offs

- [误删说明正文] → 规则明确留 `:` 后文本；抽查高密度文件。
- [只删一侧留下 `[UE--]`] → 完成后对 `Plugins/Angelscript/Source` 做全量 grep。
- [后人按旧策略继续加标] → 现行文档改成禁止新增。
- [双仓库漏提交] → 源码在子模块，OpenSpec/文档在父仓库，先子模块后 gitlink。
