# 杂项系统覆盖矩阵（CVar / AnimInstance）

> **本矩阵是 CVar / AnimInstance 测试的设计规格("头")**：每行是一个**具体可验证场景**。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🟡＝部分覆盖（待加深），🚫＝fork 不支持。
>
> - 测试文件：`CVar`(11) / `AnimInstance`(3) Tests.cpp
> - Automation 前缀：`Angelscript.TestModule.Coverage.CVar`、`...Animation.AnimInstance`
> - 图例见 `../coverage-matrix.md`。

## 1. 控制台变量 CVar（CVarTests 11）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 全类型 Get/Set | ✅ | `CVarGetSetAllTypes` |
| 安全访问与既有变量 / 既有变量保留原生元数据 | ✅ | `CVarSafeAccessAndExistingVariable` `CVarExistingVariablePreservesNativeMetadata` |
| 既有引擎 CVar 冒烟（保留并恢复值） / 渲染与可伸缩性 CVar 保留恢复 | ✅ | `ExistingEngineCVarSmokePreservesAndRestoresValues` `ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues` |
| 已注册 CVar 名矩阵 / 常见使用模式 | ✅ | `RegisteredCVarNameMatrix` `CommonCVarUsagePatterns` |
| 控制台命令注册/参数/卸载 / 常见字符串矩阵分发 | ✅ | `ConsoleCommandRegistrationArgumentsAndUnload` `ConsoleCommandCommonStringMatrixDispatch` |
| 控制台命令执行 API 不支持 | 🚫 | `ConsoleCommandExecutionApisUnsupported` |
| 控制台命令字符串构造编译边界 | 🚫 | `ConsoleCommandStringConstructionCompileBoundary` |

## 2. 动画实例 AnimInstance（AnimInstanceTests 3）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| UAnimInstance 子类与变量声明 | ✅ | `AnimInstanceSubclassAndVariables` |
| 查询函数可编译 | ✅ | `AnimInstanceQueryFunctionsCompile` |
| asset-free owner / montage / curve 查询运行期行为 | ✅ | `AnimInstanceQueryFunctionsExecute` |
| 状态机/动画通知等需要真实动画资产或图的运行期路径 | 🚫 | 本轮不纳入 headless asset-free Coverage 范围；后续若引入专用测试资产再另开行 |

---

## 汇总

| 文件 | 方法 |
|------|------|
| CVar | 11 |
| AnimInstance | 3 |
| **合计** | **14** |

**已关闭**：G1 — `AnimInstanceQueryFunctionsExecute` 通过 transient `USkeletalMeshComponent` outer 实例化 AS `UAnimInstance`，反射执行 owner / montage / curve 查询并断言 asset-free 状态。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Animation.AnimInstance"` → `3/3`。
