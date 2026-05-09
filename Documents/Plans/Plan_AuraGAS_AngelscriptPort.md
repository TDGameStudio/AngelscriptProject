# Plan: Aura GAS — AngelScript 移植

> **目标**：将 Udemy 课程"Unreal Engine 5 - Gameplay Ability System - Top Down RPG"（作者 Stephen Ulibarri / DruidMech）的 Aura 项目从 C++ 实现移植为 AngelScript 实现，验证本项目 Angelscript 插件的 GAS 集成能力。

---

## 一、项目背景

### 1.1 原始课程

| 项 | 值 |
|----|-----|
| 课程 | Unreal Engine 5 - Gameplay Ability System - Top Down RPG |
| 平台 | Udemy |
| 作者 | Stephen Ulibarri (DruidMech) |
| 课程章节 | ~25+ Sections, 400+ 节视频 |
| 引擎版本 | UE 5.2 → 5.3 |
| 编程语言 | C++ + Blueprint |

### 1.2 参考资源

| 资源 | 位置 | 用途 |
|------|------|------|
| Aura 初始项目（美术资产） | `Reference/GameplayAbilitySystem_Aura_Initial` | 课程起始资产包（已拉取） |
| Aura C++ 完整实现 | `Reference/GameplayAbilitySystem_Aura_Cpp` | C++ 参考代码（已拉取） |
| DeepWiki 架构文档 | https://deepwiki.com/DruidMech/GameplayAbilitySystem_Aura | 自动生成的架构分析 |
| CNGoSeI 中文笔记 | https://github.com/CNGoSeI/GASAura | 中文实现笔记 |
| 当前项目 Aura 资产 | `Content/Aura/` | 620 个资产已导入 |

### 1.3 当前 AngelScript GAS 基础设施

`Plugins/AngelscriptGAS/Source/AngelscriptGAS/` 已提供独立的 GAS 扩展插件能力：

| 文件 | 功能 |
|------|------|
| `AngelscriptAbilitySystemComponent` | AS 可继承的 ASC |
| `AngelscriptGASAbility` | AS 可继承的 GameplayAbility 基类 |
| `AngelscriptGASCharacter` | AS 可继承的 GAS Character 基类 |
| `AngelscriptGASPawn` | AS 可继承的 GAS Pawn |
| `AngelscriptGASActor` | AS 可继承的 GAS Actor |
| `AngelscriptAttributeSet` | AS 可继承的 AttributeSet |
| `AngelscriptAbilityTask` | AS 可继承的 AbilityTask |
| `AngelscriptAbilityTaskLibrary` | AS 任务辅助库 |
| `AngelscriptGameplayCueUtils` | Gameplay Cue 工具 |

---

## 二、Aura 项目架构（C++ 原版）

### 2.1 核心系统

```
┌─────────────────────────────────────────────────────┐
│                  Aura GAS Framework                  │
├──────────┬──────────┬──────────┬──────────┬─────────┤
│ Character│ Ability  │ Combat   │   UI     │Save/Load│
│  System  │  System  │  System  │  System  │ System  │
├──────────┴──────────┴──────────┴──────────┴─────────┤
│         Unreal Engine Gameplay Ability System        │
└─────────────────────────────────────────────────────┘
```

### 2.2 角色继承体系

```
ACharacter
  └── AAuraCharacterBase (抽象基类，实现 ICombatInterface + IAbilitySystemInterface)
        ├── AAuraCharacter      (玩家角色)
        └── AAuraEnemy          (敌人基类)
              ├── Ghoul
              ├── Goblin_Slingshot
              ├── Goblin_Spear
              └── Demon
```

### 2.3 属性系统

| 层级 | 属性 | 说明 |
|------|------|------|
| **Primary** | Strength, Intelligence, Resilience, Vigor | 基础属性，通过等级/装备提升 |
| **Secondary** | Armor, ArmorPen, BlockChance, CritHitChance, CritHitDamage, CritHitResistance, HealthRegen, ManaRegen, MaxHealth, MaxMana | 由 Primary 派生 |
| **Vital** | Health, Mana | 实时变化 |
| **Meta** | IncomingDamage, IncomingXP | 临时属性，用于计算 |

### 2.4 技能体系

| 类型 | 示例 | 说明 |
|------|------|------|
| **Offensive Spells** | FireBolt, Lightning, ArcaneShards | 远程法术投射物 |
| **Passive Abilities** | HaloOfProtection, LifeSiphon, ManaSiphon | 持续被动效果 |
| **Summon** | SummonAbility | 召唤仆从 |
| **Melee Attack** | MeleeAttack | 近战普通攻击 |

### 2.5 敌人 AI

- Behavior Tree + Blackboard
- 巡逻 → 发现玩家 → 进入战斗 → 施放技能/攻击
- 多种敌人类型（近战 Ghoul、远程 Goblin Slingshot、法师 Demon）

### 2.6 UI 系统（MVVM）

```
View (UMG Widgets)
  ← WidgetController (ViewModel)
    ← AbilitySystemComponent / PlayerState (Model)
```

- OverlayWidgetController：HUD（血条、蓝条、经验条）
- SpellMenuWidgetController：技能菜单（学习、装备、升级）
- AttributeMenuWidgetController：属性面板

### 2.7 存档系统

- 多存档槽（3 个）
- 检查点自动存档
- 保存：等级、经验、属性点、技能点、已学技能、世界 Actor 状态

---

## 三、AngelScript 移植策略

### 3.1 核心原则

1. **AS 优先**：所有游戏逻辑用 AngelScript 实现，只在 AS 无法做到时才用 C++/Blueprint
2. **逐步验证**：每个 Phase 完成后运行测试验证
3. **参考 C++ 但不照搬**：利用 AS 的动态性简化设计
4. **复用现有资产**：`Content/Aura/` 620 个美术资产直接使用

### 3.2 AS 对应 C++ 的映射

| C++ 原版 | AngelScript 移植 |
|----------|-----------------|
| `AAuraCharacterBase` (C++) | `class UAuraCharacterBase : UAngelscriptGASCharacter` |
| `AAuraCharacter` (C++) | `class UAuraCharacter : UAuraCharacterBase` |
| `AAuraEnemy` (C++) | `class UAuraEnemy : UAuraCharacterBase` |
| `UAuraAbilitySystemComponent` | `class UAuraASC : UAngelscriptAbilitySystemComponent` |
| `UAuraAttributeSet` | `class UAuraAttributeSet : UAngelscriptAttributeSet` |
| `UAuraGameplayAbility` | `class UAuraAbility : UAngelscriptGASAbility` |
| `ICombatInterface` (C++) | AS class with BlueprintCallable methods |
| Widget Controller (C++) | AS class extending UObject |

---

## 四、实施阶段

### Phase 1: 基础框架（角色 + 属性）

**目标**：玩家角色能在场景中移动，拥有属性系统。

| 任务 | 说明 |
|------|------|
| 1.1 创建 `AuraCharacterBase.as` | 继承 `UAngelscriptGASCharacter`，设置 ASC 和 AttributeSet |
| 1.2 创建 `AuraAttributeSet.as` | 定义 Primary/Secondary/Vital 属性 |
| 1.3 创建 `AuraCharacter.as` (玩家) | 俯视角控制、相机、Enhanced Input 绑定 |
| 1.4 属性初始化 | 通过 GameplayEffect 初始化默认属性值 |
| 1.5 Secondary 属性派生 | 定义 Secondary = f(Primary) 的计算关系 |

**验证**：运行 PIE，玩家角色显示在场景中，属性值正确初始化。

---

### Phase 2: 战斗核心（伤害 + 投射物）

**目标**：玩家能施放法术攻击并对敌人造成伤害。

| 任务 | 说明 |
|------|------|
| 2.1 创建 `AuraProjectile.as` | 投射物 Actor，带碰撞和运动组件 |
| 2.2 创建 `FireBolt.as` (Ability) | 第一个攻击技能，生成投射物 |
| 2.3 伤害计算 | `ExecCalc_Damage`：基于属性计算最终伤害 |
| 2.4 创建 `AuraEnemy.as` | 敌人基类，有血条、可受伤 |
| 2.5 死亡与溶解 | 角色死亡流程 + 材质溶解效果 |
| 2.6 GameplayCue | 命中特效、死亡特效 |

**验证**：玩家施放 FireBolt，击中敌人造成伤害，敌人死亡播放动画。

---

### Phase 3: 属性与效果

**目标**：完整的属性交互和状态效果系统。

| 任务 | 说明 |
|------|------|
| 3.1 暴击系统 | Critical Hit Chance / Damage / Resistance |
| 3.2 护甲与穿透 | Armor 和 Armor Penetration 影响伤害 |
| 3.3 Debuff 系统 | 燃烧 (Burn)、眩晕 (Stun)、持续伤害 |
| 3.4 抗性系统 | 火焰/闪电/奥术/物理抗性 |
| 3.5 生命/法力回复 | HealthRegen、ManaRegen per second |

**验证**：多种属性正确影响伤害计算，Debuff 正确应用和视觉反馈。

---

### Phase 4: 多技能 + 被动

**目标**：完整的技能体系。

| 任务 | 说明 |
|------|------|
| 4.1 Lightning 法术 | 闪电链攻击 |
| 4.2 ArcaneShards 法术 | 多段奥术碎片 |
| 4.3 Summon 技能 | 召唤仆从 AI |
| 4.4 被动技能框架 | HaloOfProtection、LifeSiphon、ManaSiphon |
| 4.5 技能升级 | 技能等级影响伤害/CD/效果 |

**验证**：多种技能可施放，被动持续生效，升级后数值正确变化。

---

### Phase 5: 敌人 AI

**目标**：敌人有自主行为。

| 任务 | 说明 |
|------|------|
| 5.1 AI Controller | Behavior Tree + Blackboard 集成 |
| 5.2 巡逻行为 | 敌人在路径点间巡逻 |
| 5.3 战斗行为 | 发现玩家后追击/攻击 |
| 5.4 多种敌人 | Ghoul（近战）、Goblin（远程）、Demon（法师） |
| 5.5 Hit React | 受击反馈动画 |

**验证**：敌人巡逻、发现玩家、攻击、死亡全流程。

---

### Phase 6: UI 系统

**目标**：完整的游戏 UI。

| 任务 | 说明 |
|------|------|
| 6.1 HUD Overlay | 血条、蓝条、经验条 |
| 6.2 Widget Controller 框架 | MVVM 数据绑定 |
| 6.3 伤害数字 | 浮动伤害文字 |
| 6.4 敌人血条 | 敌人头顶血条 |
| 6.5 技能菜单 | 技能学习/装备界面 |
| 6.6 属性菜单 | 属性点分配界面 |

**验证**：UI 正确显示并响应属性变化。

---

### Phase 7: 角色成长

**目标**：等级和成长系统。

| 任务 | 说明 |
|------|------|
| 7.1 经验系统 | 击杀获得 XP |
| 7.2 等级系统 | XP 累积升级，等级曲线 |
| 7.3 属性点 | 升级获得属性点，可分配 |
| 7.4 技能点 | 升级获得技能点，可学习/升级技能 |
| 7.5 职业系统 | 不同职业影响基础属性和成长 |

**验证**：杀敌获得经验，升级后分配点数。

---

### Phase 8: 存档 + 关卡

**目标**：完整的游戏循环。

| 任务 | 说明 |
|------|------|
| 8.1 存档系统 | 多槽位存档/读档 |
| 8.2 检查点 | 场景中的自动存档点 |
| 8.3 关卡设计 | 使用 Dungeon tileset 搭建关卡 |
| 8.4 Effect Actors | 场景中的交互效果（火焰区域等） |
| 8.5 拾取物 | 药水、金币拾取 |

**验证**：完整游戏流程可玩。

---

## 五、风险与注意事项

| 风险 | 影响 | 应对 |
|------|------|------|
| AS 的 GAS 绑定可能不完整 | 某些 GAS 功能在 AS 中不可用 | 逐步验证，必要时在 C++ 层补充绑定 |
| Behavior Tree 可能需要 C++/Blueprint | AS 对 BT Task/Decorator 的支持待验证 | 可用 Blueprint 做 AI，AS 做逻辑 |
| ExecCalc 在 AS 中的实现方式 | 伤害计算是 GAS 核心 | 确认 `UGameplayEffectExecutionCalculation` 是否可 AS 继承 |
| Widget Controller 在 AS 中的 MVVM 模式 | UI 数据绑定 | 可能需要适配 AS 的委托/事件系统 |
| 多行代码执行限制 | MCP 工具调试不便 | 已解决（exec 包装） |
| Enhanced Input 动态委托签名漂移 | PIE 中 `BindUFunction` 会运行时拒绝旧签名 | AS handler 必须匹配 UE 5.7 `FEnhancedInputActionHandlerDynamicSignature`：`FInputActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction` |
| AS `UFUNCTION()` 签名热重载限制 | 编辑器可能继续运行旧 UFUNCTION，导致误判修复无效 | 修改 `UFUNCTION()` 参数列表后必须 Full Reload 或重启编辑器，再重新 PIE 验证 |

---

## 六、成功标准

- [ ] 玩家角色可在地牢场景中移动、施放 3+ 种法术
- [ ] 敌人有 AI 行为，可被攻击并死亡
- [ ] 完整的属性和伤害计算系统
- [ ] UI 正确显示血量、法力、经验
- [ ] 升级和技能学习系统可用
- [ ] 存档/读档功能正常
- [ ] 全部用 AngelScript 实现（AI 部分可用 Blueprint 辅助）

---

## 七、预估工作量

| Phase | 预估时间 | 优先级 |
|-------|----------|--------|
| Phase 1: 基础框架 | 2-3 天 | P0 |
| Phase 2: 战斗核心 | 3-4 天 | P0 |
| Phase 3: 属性与效果 | 2-3 天 | P1 |
| Phase 4: 多技能 | 3-4 天 | P1 |
| Phase 5: 敌人 AI | 3-4 天 | P1 |
| Phase 6: UI 系统 | 4-5 天 | P2 |
| Phase 7: 角色成长 | 2-3 天 | P2 |
| Phase 8: 存档+关卡 | 3-4 天 | P3 |
| **总计** | **~22-30 天** | |

---

## 八、当前实施记录

### 8.1 Phase 1.3 角色输入初版（记录日期：2026-05-06）

本轮处理的是 Aura 玩家角色的 Enhanced Input 绑定问题，属于 Phase 1.3 "俯视角控制、相机、Enhanced Input 绑定" 的基础闭环。

| 项 | 结果 |
|----|------|
| 目标 | `AAuraCharacter` 在 `AuraDevMap` 中进入 PIE 时能完成输入绑定，不再因动态委托签名不兼容报错 |
| 主要脚本 | `Script/Aura/Character/AuraCharacter.as` |
| 相关示例 | `Script/Examples/EnhancedInput/Example_EI_Component.as`、`Script/Examples/EnhancedInput/Example_EI_PlayerController.as` |
| 回归测试 | `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptEnhancedInputBindingsTests.cpp` |
| 测试依赖 | `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` 增加 `EnhancedInput` |

#### 实现要点

- Aura 玩家角色继续保持游戏逻辑写在 AS 中，不通过 Blueprint 实现输入逻辑。
- `AAuraCharacter::Move` 的 `UFUNCTION()` 签名已对齐 UE 5.7 的 `FEnhancedInputActionHandlerDynamicSignature`：

```angelscript
void Move(FInputActionValue ActionValue, float32 ElapsedTime, float32 TriggeredTime, const UInputAction SourceAction)
```

- 旧签名 `void Move(FInputActionValue, float, FInputActionInstance, UInputAction)` 会在 PIE 输入绑定阶段触发：

```text
Specified function is not compatible with delegate function.
```

- 本次同步修正 `Script/Examples/EnhancedInput/` 下的示例 handler，避免示例继续传播旧签名。
- 新增 EnhancedInput 绑定回归：编译一个 AS `AActor`，通过 `FEnhancedInputActionHandlerDynamicSignature.BindUFunction` 绑定 AS `UFUNCTION()`，再验证 `UEnhancedInputComponent.BindAction` 创建的绑定对象、Action 和 TriggerEvent 正确。
- 该回归刻意不使用手工 `FEnhancedInputActionEventBinding::Execute` 作为验收条件；当前测试 harness 中手工执行路径不等价于真实 PIE 输入派发，容易产生错误负例。此处测试重点是本次真实故障点：动态委托签名兼容与 `BindUFunction` 绑定创建。

#### 验证记录

| 验证 | 命令/方式 | 结果 |
|------|-----------|------|
| 构建 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label aura-enhinput-signature -TimeoutMs 180000` | 通过，exit `0` |
| EnhancedInput 自动化 | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings.EnhancedInput" -Label aura-enhinput-signature -TimeoutMs 600000` | `total=8 passed=8 failed=0 skipped=0` |
| MCP Python | `ue_eval_python("1 + 1")` | 返回 `2` |
| 地图验证 | 打开 `/Game/Aura/Maps/AuraDevMap` 后触发 PIE | PIE 成功启动，`Play in editor total start time 0.104 seconds` |
| 日志验证 | 扫描本次 PIE 时间段 `2026.05.04-12.03.*` | 未再出现 `Specified function is not compatible with delegate function` / `Attempted Bind` |

#### 后续约束

- 后续新增 `FEnhancedInputActionHandlerDynamicSignature` handler 时，统一使用 `float32 TriggeredTime` 作为第三个参数，不使用 `FInputActionInstance`。
- 只要 AS `UFUNCTION()` 参数列表变化，必须重启编辑器或触发 full reload 后再验证 PIE；热重载提示 `Full Reload is required ... Keeping old angelscript code active` 时，日志中的旧错误不能作为新代码结果判断。
- Aura 角色、输入、ASC、属性和技能逻辑继续放在 `Script/Aura/` 下，目录隔离保持为后续示例项目共存的前提。
- `Content/Aura/` 资产只作为 Aura 示例资产目录使用；后续新增资源优先放入 `Content/Aura/` 子目录，避免和其他示例项目混放。

---

## 附录 A：Aura 文字资料与可采信顺序

> 本附录用于执行移植时快速定位"文字版整理"来源。Aura 课程本体以视频为主，公开仓库更偏代码与资产；执行时应按下列顺序采信，避免把学习者二次整理误当成原始课程事实。

### A.1 首选资料

| 优先级 | 资料 | 地址/位置 | 适合用途 | 使用边界 |
|--------|------|-----------|----------|----------|
| P0 | Aura C++ 完成态源码 | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/` | 类结构、函数边界、GAS 数据流、GameplayTag 命名、UI/MVVM 接入、存档与 AI 控制流 | 当前本地副本只有 `main` 的单提交快照；不要用它还原每一课的历史顺序 |
| P0 | Aura 初始资产项目 | `Reference/GameplayAbilitySystem_Aura_Initial/` | 起始资产、地图、UI/角色/敌人/地牢素材目录、UE 5.2 初始项目结构 | 只代表课程起始包，不代表完成态实现 |
| P0 | 官方课程页 | https://www.udemy.com/course/unreal-engine-5-gas-top-down-rpg/ | 确认课程名称、作者、主题范围、目标系统和总体覆盖面 | 课程正文多数在视频内，公开页面不提供完整文字讲义 |
| P0 | DruidMech 官方仓库 | https://github.com/DruidMech/GameplayAbilitySystem_Aura | 确认上游仓库、初始提交、完成态 `main` 分支和授权范围 | 仓库本身缺少系统化 README，主要仍是代码/资产事实源 |

### A.2 可直接参考的文字版整理

| 优先级 | 资料 | 地址 | 适合用途 | 使用边界 |
|--------|------|------|----------|----------|
| P1 | DeepWiki 架构文档 | https://deepwiki.com/DruidMech/GameplayAbilitySystem_Aura | 快速理解模块划分、调用链和代码结构；适合作为执行前的架构导读 | 自动生成文档，必须回查本地 C++ 源码确认关键细节 |
| P1 | AngelscriptAura 第三方 AS 改写 | `Reference/AngelscriptAura/`；https://github.com/najoast/AngelscriptAura | 参考 Aura GAS 在 Angelscript 中的脚本分层、GAS API 调用、属性集、伤害计算、角色/AI/UI 组织和实现笔记 | 不是官方课程完成态；完成度低于 Aura C++ `main`，关键行为必须回查 C++ 源码和当前插件绑定能力 |
| P1 | CNGoSeI 中文笔记 | https://github.com/CNGoSeI/GASAura | 中文章节笔记、概念翻译、课程流程梳理；适合给中文执行者补上下文 | 学习者笔记，不保证与当前上游 `main` 或本项目目标完全一致 |
| P1 | Tallino 英文长 README | https://github.com/Tallino/GameplayAbilitySystem_Aura | 英文文字版课程整理，覆盖 GAS 组件、属性、技能、UI、存档等实现笔记 | 第三方 fork，内容可能包含作者本人的理解和改动；只作辅助索引 |

### A.3 本地 C++ 源码索引

| 系统 | 首查路径 | 移植时关注点 |
|------|----------|--------------|
| 角色/敌人 | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/Character/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/Character/` | `AAuraCharacterBase`、`AAuraCharacter`、`AAuraEnemy` 的 ASC 初始化、死亡、受击、职业等级和接口实现 |
| Ability System | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/AbilitySystem/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/AbilitySystem/` | `UAuraAbilitySystemComponent`、`UAuraAttributeSet`、`UAuraAbilitySystemLibrary`、自定义 EffectContext、属性初始化和 Ability 授予 |
| 技能实现 | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/AbilitySystem/Abilities/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/AbilitySystem/Abilities/` | `AuraGameplayAbility`、`AuraDamageGameplayAbility`、`AuraProjectileSpell`、`FireBolt`、`Electrocute`、`ArcaneShards`、被动技能和召唤 |
| 伤害计算 | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/AbilitySystem/ExecCalc/ExecCalc_Damage.cpp` | 护甲、格挡、暴击、抗性、Debuff、击退、死亡冲量和 radial damage 的计算边界 |
| Gameplay Tags | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/AuraGameplayTags.h`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/AuraGameplayTags.cpp` | AS 侧应尽量保持 tag 命名兼容，方便复用资产和数据表 |
| UI/MVVM | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/UI/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/UI/` | WidgetController、HUD、LoadScreen ViewModel、属性/技能菜单广播方式 |
| 玩家控制/Input | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/Player/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/Input/` | Top-down 点击移动、技能输入 Tag、Enhanced Input 和 ASC 绑定 |
| AI | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/AI/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Private/AI/` | BTService/BTTask 能否直接转 AS；若绑定不足，保留 Blueprint/BT 作为辅助层 |
| 存档/关卡 | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/Game/`、`Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/Checkpoint/` | SaveGame 数据结构、MapEntrance、Checkpoint、世界状态保存和 LoadScreen 流程 |
| 交互接口 | `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/Public/Interaction/` | `CombatInterface`、`PlayerInterface`、`EnemyInterface`、`SaveInterface` 在 AS 中的替代方式 |

### A.4 执行时检索建议

- 先用 DeepWiki 或学习者笔记确认一个系统的课程语义，再回到 `Reference/GameplayAbilitySystem_Aura_Cpp/Source/Aura/` 查真实 C++ 落点。
- 需要 AS 侧写法时，可先看 `Reference/AngelscriptAura/Script/GAS/` 和 `Reference/AngelscriptAura/Script/Documents/`，再对照 Aura C++ 完成态确认行为是否完整。
- 涉及 GameplayEffect、GameplayAbility、AttributeSet、EffectContext、AbilityTask、MVVM、SaveGame 时，必须额外检查 `Plugins/AngelscriptGAS/Source/AngelscriptGAS/` 的 AS 暴露能力。
- 文字资料只用于降低理解成本；最终验收以本地 Aura C++ 源码、当前 `Content/Aura/` 资产和 Angelscript 插件实际绑定能力为准。
