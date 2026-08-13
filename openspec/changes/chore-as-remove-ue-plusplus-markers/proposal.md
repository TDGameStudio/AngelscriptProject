## Why

`[UE++]` / `[UE--]` 当初用来把 ThirdParty AngelScript 标成「贴在官方 SDK 上的 UE 补丁」，方便 3-way merge。当前产品已经是 Unreal 内置脚本方言，不再把内核当可整包 rebase 的 vendor overlay，继续维护这套围栏会假装耦合边界还在、并强迫新改动继续打标。

## What Changes

- 从插件 C++ 源码去掉全部 `[UE++]` / `[UE--]` 标记；`//[UE++]: 说明` 保留为普通注释。
- 现行策略/知识文档不再要求新改动加这对标记。
- 历史 `Documents/Plans/` 与已有 OpenSpec 叙述不改写。

## Capabilities

### New Capabilities

- `as-source-marker-policy`: 插件源码不得再要求或新增 `[UE++]` / `[UE--]` 分叉围栏；说明性注释可以保留。

### Modified Capabilities

- （无。共享 `openspec/specs/` 没有把加标记写成现行 requirement。）

## Impact

- 源码：`Plugins/Angelscript` 子模块中 ThirdParty 内核、`Core/angelscript.h`、以及少数 Runtime / ClassGenerator / Preprocessor 文件的注释。
- 文档：`AngelscriptForkStrategy.md`、`RT_ThirdPartyKernel.md`、`AS_ForkDifferences.md`、`AS_UEEmbeddedVersion.md` 及少量知识文里的现行硬规则。
- 无 API、ABI、构建或测试行为变化。没有 Tools / 测试脚本依赖这些标记。
