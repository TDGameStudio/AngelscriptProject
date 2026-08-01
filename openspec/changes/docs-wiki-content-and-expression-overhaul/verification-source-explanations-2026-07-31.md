# 源码解释组件正式落地验证（2026-07-31）

## 本批范围

- 恢复 experiment 19 方向的 note 编号、完整点击热区、披露符号与阅读提示。
- 新增生命周期、状态迁移、调用序列、数据流、AST 和 VM 六类源码解释组件。
- 新增正式 Showcase Pattern `P07`–`P10` 与 Lab `L01`–`L02`。
- 使用固定 revision 的源码快照；AST/VM JSON 数据声明 `schemaVersion: 1` 与 fidelity。
- 不增加外部运行时依赖，不把实验 14–17 的第三方库带入正式 Wiki。

## 通过项

| 验证 | 结果 | 覆盖 |
|---|---:|---|
| `pnpm run check` | PASS | TypeScript 编译与项目静态检查 |
| 新增/修改文件的 ESLint 定向检查 | PASS | widget、样式与 Playwright 用例 |
| `pnpm run test:feature code` | 36/36 PASS | note 披露、六类组件、双向联动、schema/fidelity、窄屏、键盘、reduced-motion、打印、observer teardown |
| `pnpm run test:document-content` | 48/48 PASS | Showcase 目录、页面/fixture 归属、revisioned 源码与数据合同 |
| `pnpm run build:wiki` | PASS | 单文件 Wiki 构建 |
| `pnpm run test:artifact` | 1/1 PASS | 完整离线发布产物且不修改交互源 |
| `pnpm run test:runtime` | 1/1 PASS | Wiki runtime smoke |
| `pnpm run test:product-sources` | 4/4 PASS | 产品来源约束 |
| `pnpm run test:source-bridge` | 3/3 PASS | 固定源码桥接 |
| `pnpm run test:multilingual` | 3/3 PASS | 多语言契约 |
| `pnpm run test:product-test-infrastructure` | 19/19 PASS | 产品测试基础设施 |

桌面截图人工复核：

- `Wiki/test-results/manual-p07.png`：源码保持连续；短 note 位于代码块内部右侧窄 lane；流程结构位于源码之后。
- `Wiki/test-results/manual-l02.png`：源码仍为视觉主体；固定输入场景明确标为 `recorded-source-level`；手动上一步/下一步轨迹不冒充实时 VM 或虚构 opcode。

### 行范围与 connector 层级修正

任务 2.17 使用 TDD 修正了两个生产视觉问题：

- RED：带四个缩进字符的整行注解 mark 相对实际源码字符左偏 `34.65625px`；connector 默认 `z-index` 为 `4`；空行锚点仍有 `solid` 下边框。
- GREEN：无 `match` 的范围逐行裁剪首尾空白，范围内空行不产生可见 mark；显式空行注解保留不可见几何锚点。精确 `match` 的 DOM Range 路径不变。
- connector SVG 默认 `z-index: 0`，hover/focus 不提升；详情打开时切换为 `z-index: 4`，只有当前 `.is-active` 路径保持 `opacity: 1`，同层其他路径为 `0`；关闭、切换、外部点击与 `Escape` 恢复低层。

新鲜验证：

| 验证 | 结果 |
|---|---:|
| `pnpm run test:feature code` | 36/36 PASS |
| `pnpm run check` | PASS |
| 修改文件的 ESLint 定向检查 | PASS（0 errors，0 warnings） |
| `pnpm run build:wiki` | PASS |
| `pnpm run test:artifact` | 1/1 PASS |

视觉复核：

- `Wiki/test-results/fixed-p02-default.png`：第 60–61、67–68 行的 mark 从每行第一个实际代码字符开始，不覆盖缩进。
- `Wiki/test-results/fixed-p04-default.png`：AngelScript 与 C++ 多行范围均逐行贴合源码墨迹。
- `Wiki/test-results/fixed-p02-clicked.png`：默认线位于源码下层；点击“越过左边界”后，仅当前蓝色关系线提升并连接到打开的详情。

## 全域基线说明

`pnpm run test:feature document` 当前为 `22/24 PASS`。本批新增的 Pattern/Lab、目录与源码映射断言全部通过；剩余两项是开始本批前已存在且与源码解释组件无关的文档基线：

1. 旧断言仍查找 `.tc-tiddler-body ol a.tc-tiddlylink` 的 L1–L5 列表，而当前 landing 已采用 `as-doc-cards`。
2. 旧断言要求三个 placeholder internals 页面存在 `View pinned source` 链接，但这些页面尚未承载对应 excerpt。

仓库级 `pnpm run lint` / `test:fast` / `test:release` 仍受既有 `tests/playwright/product/tools/tiddler-toolbar-hover-prototype.spec.ts` 九个 unnecessary type assertion 错误阻断。本批新增/修改的 lint 范围通过；这里不顺带改写不相关工具原型或旧内容契约。

## 结论

任务 2.14–2.17 的实现与范围内验证已完成。组件保持连续源码、源码内低强调 note、轻量连接、按需详情、窄屏组件内滚动、打印静态化与完整 teardown；正式 Wiki 生产路径没有新增第三方运行时依赖。
