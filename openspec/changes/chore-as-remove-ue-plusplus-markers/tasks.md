## 1. Record

- [x] 1.1 Create the OpenSpec change and write proposal, design, spec, and this task list

## 2. Source

- [ ] 2.1 <!-- Non-TDD --> Strip `[UE++]` / `[UE--]` from UE-layer files: `Core/angelscript.h`, `Core/AngelscriptEngine.cpp`, ClassGenerator reload files, and `AngelscriptPreprocessor.cpp`
- [ ] 2.2 <!-- Non-TDD --> Strip `[UE++]` / `[UE--]` from `ThirdParty/angelscript/source` headers and sources, keeping rationale text

## 3. Docs

- [ ] 3.1 <!-- Non-TDD --> Stop requiring fences in `AngelscriptForkStrategy.md`, `RT_ThirdPartyKernel.md`, `AS_ForkDifferences.md`, `AS_UEEmbeddedVersion.md`, and related living knowledge articles

## 4. Verify

- [ ] 4.1 <!-- Non-TDD --> Confirm `Plugins/Angelscript/Source` C++ files contain no `[UE++]` or `[UE--]`, and spot-check that comment bodies remain

> 本轮只完成记录。源码和现行策略文档先不动，等明确开始 apply 再做 2–4。
