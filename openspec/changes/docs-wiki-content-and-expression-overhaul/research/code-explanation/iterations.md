# 源码解释实验账本

| 轮次 | 编号 | 主要假设 | 语言 / 内容 | 当前判断 |
|---|---|---|---|---|
| 第一轮 | 01 | 行桥接可以建立源码与解释关系 | AS / `ApplyDamageToTarget` | 关系明确，但代码和解释形成并行阅读任务 |
| 第一轮 | 02 | 执行收据可以解释一次具体运行 | AS / `ApplyDamageToTarget` | 适合调试证据，不适合作为普通源码主阅读面 |
| 第一轮 | 03 | 路由视图可以解释长 C++ 初始化 | C++ / `InitializeAngelscript` | 所有权清楚，但整体布局偏重 |
| 第一轮 | 04 | 跨语言边界图可以解释 AS→C++ | AS + C++ / reflective boundary | 适合边界专题，不是普通函数批注 |
| 第二轮 | 05 | 解释条进入代码阅读顺序可减少跨栏寻找 | AS / `ApplyDamageToTarget` | 解释易找，但源码视觉形状被解释条切断 |
| 第二轮 | 06 | token 脚注可精确解释表达式 | AS / `ApplyDamageToTarget` | 精确但密度较高，脚注仍进入代码纵向流 |
| 第二轮 | 07 | 代码段前批注适合 C++ 原理 | C++ / `InitializeAngelscript` | WHY/OWNERSHIP/INVARIANT 有效，但函数不再连续 |
| 第二轮 | 08 | 运行值紧跟源码可解释分支 | AS / `ApplyDamageToTarget` | 运行证据清楚，但运行 note 改变代码纵向节奏 |
| 第三轮 | 09 | 小型右侧轨与低调直连可保留 AS 源码形状 | AS / `ApplyDamageToTarget` | 源码完整且侧轨明显轻于源码，但仍形成一次向右寻找 |
| 第三轮 | 10 | 范围括线可把长 C++ 代码段连接到窄边注轨 | C++ / `InitializeAngelscript` | 长函数范围关系稳定；加宽代码纸张后真实长行不再裁切，但 note 仍在源码块外 |
| 第三轮 | 11 | 贴在代码纸面边缘的短标签可避免固定侧栏 | AS / `ApplyDamageToTarget` | 无固定栏但标签仍在代码纸张外侧；用户审阅后明确不是当前首选 |
| 第三轮 | 12 | 自由边注和轻量曲线可解释 C++ 范围而不建立规则第二栏 | C++ / `InitializeAngelscript` | C++ 生命周期解释清楚且长行完整；自由 note 仍位于代码纸张两侧 |
| 第三轮 | 13 | note 作为覆盖层进入亮色代码块内部可兼顾就近解释与源码连续性 | AS / `ApplyDamageToTarget` | 当前最接近目标：note 视觉内嵌、短线只在代码块内，源码 DOM 与复制文本保持纯净 |
| 第四轮 | 14 | 动态 lane 可让短 note 主动寻找代码内部空白 | AS / Enhanced Input `BeginPlay` | 当前零依赖基线：真实源码宽度驱动纸张，note 按碰撞检测进入三条内部 lane；外观与职责都最容易收敛到正式组件 |
| 第四轮 | 15 | LinkerLine 可接管滚动容器内的连接器生命周期 | C++ / `FAngelscriptBinds::CallBinds` | 正交线与滚动/重定位可靠，但 108,262-byte 内联运行时对“轻注释”偏重；适合作为生命周期参考，不宜默认引入 |
| 第四轮 | 16 | Perfect Arrows 的几何输出可以柔化关系线 | AS / `ApplyDamageToTarget` interface dispatch | 6,239-byte 体积很小，曲线易实现；但并不负责 DOM 生命周期、碰撞或详情定位，且箭头语义与“对应关系”冲突，因此只取控制点、不画箭头头部 |
| 第四轮 | 17 | Floating UI 可以专门解决长解释的边缘避让 | C++ / `EnsurePrimaryEngineInitialized` | `flip` / `shift` / `autoUpdate` 明确解决详情浮层问题，短 note 与关系线仍保持原生；是最有价值的可选生产依赖候选 |

## 不变原则

- `01`–`08` 是比较历史，不因当前方向变化而删除或改写。
- `09`–`13` 同样已锁定为比较历史；第四轮只追加 `14`–`17`。
- 复制源码必须得到不含行号、标签、note 和 connector 的原始文本。
- 第三轮中源码根节点只包含连续代码行；note 可位于外部或代码块内部覆盖层，但任何交互都不得移动或缩放源码行。
- 第四轮允许依赖，但依赖必须固定版本、许可证和来源，完整内联在单文件 HTML 中，并只拥有一项清楚职责。
- 单文件实验验证通过不等于正式 Wiki 组件已经 `built` 或 `tested`。
