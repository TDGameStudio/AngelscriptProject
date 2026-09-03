# TSet Advance 预期覆盖

- 日期: 2026-08-27
- 范围: 仅 `TestSource/Containers/TSet/Advance`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp`
- 约定: 上级 `../Organization.md`；单 API 正例在 `../Function/`；Throw 在 `../Exception/`

组合正例，按协议分文件。`@Harness Advance`。本地「做完再回来」标 `@Kind Observe`；给 C++ 对的入口标 `RoundTrip`。默认 `TSet<int>`，不套类型后缀。`@Tag` = `Containers.TSet.<FileStem>`。

不占 Function L1 分母。不写：存档、嵌套矩阵、种子随机 1000 步。

C++ 侧：`TSetTest::` 限定，对 `&out` / `&inout` 查写回，对返回的 `TSet<int>` / `int` / `bool` 做 **集合相等** 断言（`opEquals`），不要按迭代顺序。

---

## 文件

| 文件 | Observe | C++ RoundTrip（方向 → 期望） |
|---|---|---|
| `TSetSequence` | `SequenceFromZeroToN` | `&in` 读 members 0..4；`&out` / 返回填 0..4；`&inout` 0..2 → 0..4 |
| `TSetRestore` | Add+Remove / Remove+Add / Empty+assign | `&inout` Add 再 Remove 写回 `[10, 20]`；返回同一快照 |
| `TSetTransaction` | Commit / Rollback | `&inout` `[10,20]` → `[20,30]`；Rollback 写回仍是输入 |
| `TSetReplay` | 固定日志 | `&out` / 返回 / `&inout`（先 Empty）都是黄金 `[1, 2]` |
| `TSetSidecar` | set + id 表一起 Remove | 双 `&inout` 去掉 20；`LookupSidecarMember` 返回 int |
| `TSetCompose` | 拷值再 Add 新成员；foreach 计数 | `&inout` 增加 `30`；`SumForEachMembers(const&in)` 对三元返回 `60` |
| `TSetRoundTrip` | （无 Observe） | 通用载荷 10..50 四方向 |
