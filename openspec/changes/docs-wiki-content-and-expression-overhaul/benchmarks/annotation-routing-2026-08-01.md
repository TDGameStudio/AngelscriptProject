# 源码注解路由基线（2026-08-01）

## 目的

评估 `obstacle-router@0.1.2` 作为正式源码注解几何求解层的同步成本与离线 bundle 体积。数据只用于确定缓存和延迟阈值，不作为跨机器硬 CI 时间断言。

## 环境与方法

- Windows；初筛使用本机 Node.js 25.5.0，最终生成与验证使用 Wiki 固定工具链 Node 24.18.1 / pnpm 11.8.0。
- 初筛从 npm 临时下载 `obstacle-router@0.1.2`；最终实现已在 `Wiki/package.json` 与 lockfile 精确锁定该版本。
- 用 Wiki 已安装的 esbuild 将上游 ESM 打包后执行；每个案例创建按源码行分布的文字矩形、多个定向 point connector，并在一个 `processTransaction()` 中批量求解。
- 下列时间为舍弃首次运行后的三次平均，包含 Router/障碍/connector 创建和一次批量求解。

| 源码障碍 | note/connector | setup | route | total |
|---:|---:|---:|---:|---:|
| 100 | 8 | 0.49 ms | 11.69 ms | 12.18 ms |
| 120 | 13 | 0.40 ms | 15.26 ms | 15.66 ms |
| 200 | 32 | 0.59 ms | 29.75 ms | 30.34 ms |
| 300 | 64 | 0.85 ms | 56.14 ms | 56.99 ms |

只导入正式路由需要的符号并以 browser/CJS/minify/tree-shaking 打包后，临时 bundle 为 `138202` bytes（约 135 KiB）。最终可复现 bundle 为 `139034` bytes，SHA-256 为 `7096AFA76B69C02B2A9604EA9F96C2667194F198EF03C35FE13F0F17491386BA`；连续两次执行 `pnpm run generate:annotation-router` 哈希一致。

引入前 `Wiki/dist/index.html` 为 `5795796` bytes；最终 `pnpm run build:wiki` 产物为 `5959372` bytes，增加 `163576` bytes（包含 bundle、适配层、作者文档与许可证 tiddler）。decoded budget 因此从 `5800000` 调整为 `6000000` bytes，只保留 `40628` bytes（约 0.68%）余量；artifact 测试同时断言独立 library 模块和许可证 tiddler 确实进入单文件产物。

## 决策

- 复杂关系不超过 16 且障碍不超过 160 时，允许在合并后的布局帧内同步批量求解。
- 超过任一阈值时先渲染源码、note 和安全直线，再通过 `requestIdleCallback`（无该 API 时零延迟任务）求解复杂路径。
- 相同几何必须命中缓存；交互状态不得触发 Router。
- Router 只在一次 transaction 中存在，抽取路径后释放；SVG path 按 `noteId` 复用。
- 端点必须先从源码/短 note 障碍中切出 6px 出口；没有出口时，上游搜索会出现病态耗时。
- 上方 shelf 的路径若要避障通常必须超出端点包围框，而既有视觉契约禁止这种 overshoot，因此 top placement 直接使用低层安全 fallback，不执行 Router。
