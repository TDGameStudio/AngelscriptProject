# TMap Advance 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TMap/Advance`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp`
- 约定: 上级 `../Organization.md`；单 API 正例在 `../Function/`；Throw 在 `../Exception/`

组合正例，按协议分文件。`@Harness Advance`。本地「做完再回来」标 `@Kind Observe`；给 C++ 对的入口标 `RoundTrip`。默认 `TMap<int, int>`，不套类型后缀。`@Tag` = `Containers.TMap.<FileStem>`。

不占 Function L1 分母。不写：存档、嵌套矩阵、种子随机 1000 步。

C++ 侧：`TMapTest::` 限定，对 `&out` / `&inout` 查写回，对返回的 `TMap<int,int>` / `int` / `bool` 做 **pair 相等** 断言（`opEquals` / `IsPermutation`），不要按 GetKeys 槽位顺序。

---

## 文件

| 文件 | Observe | C++ RoundTrip（方向 → 期望） |
|---|---|---|
| `TMapSequence` | `SequenceFromZeroToN` | `&in` 读 keys 0..4；`&out` / 返回填 0..4；`&inout` 0..2 → 0..4 |
| `TMapRestore` | Add+Remove / overwrite 还原 / Empty+assign | `&inout` Add 再 Remove 写回 `[10->100, 20->200]`；返回同一快照 |
| `TMapTransaction` | Commit / Rollback | `&inout` `[10,20]` → `[20,30]`；Rollback 写回仍是输入 |
| `TMapReplay` | 固定日志 | `&out` / 返回 / `&inout`（先 Empty）都是黄金 `[1->10, 2->20]` |
| `TMapSidecar` | map + id 表一起 Remove | 双 `&inout` 去掉 20；`LookupSidecarValue` 返回 int |
| `TMapCompose` | 拷值再 Add 新键；foreach SetValue | `&inout` 增加 `30->100`；`SumForEachValues(const&in)` 对三对返回 `600` |
| `TMapRoundTrip` | （无 Observe） | 通用载荷 keys 10..50 四方向 |
