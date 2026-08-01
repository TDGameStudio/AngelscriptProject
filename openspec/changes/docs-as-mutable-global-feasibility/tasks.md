## 1. Evidence Collection

- [x] 1.1 定位脚本全局变量的 const-only、对象句柄拒绝和下划线内部逃生口。
- [x] 1.2 对照本地 vanilla AngelScript 2.38 与 Hazelight 参考快照，追踪当前仓库可验证的来源边界。
- [x] 1.3 检查全局变量编译、解释器、StaticJIT、预编译数据和 bytecode restore 路径。
- [x] 1.4 检查 module 初始化/析构、跨 module 初始化限制和原生 mutable global property 测试。
- [x] 1.5 检查 Unreal primary engine ownership、热重载 global pointer remap/reset 和 Debug Server 可观察性。

## 2. Research Record

- [x] 2.1 在 `proposal.md` 中声明研究动机、非行为变更范围和后续独立 feature change 边界。
- [x] 2.2 在 `design.md` 中区分代码事实、项目维护理由、架构推断和无法验证的历史主张。
- [x] 2.3 记录类型可行性矩阵、四类中立候选方案、风险和未来验收门槛。
- [x] 2.4 明确本 change 不创建 capability specs、不修改源码、不选择实现方案且不归档。

## 3. Validation

- [x] 3.1 运行 OpenSpec artifact status，确认 proposal、design、tasks 均被识别为完成，并记录无 delta 时 `specs` 保持 `ready`。
- [x] 3.2 运行 OpenSpec strict validation，确认当前 `spec-driven` schema 仅因 research-only change 没有 capability delta 而报告 `No deltas found`。
- [x] 3.3 检查 whitespace 和 Git diff/status，确认修改范围仅为目标 OpenSpec 目录。
