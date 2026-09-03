# TArray Advance 预期覆盖

- 日期: 2026-08-26
- 范围: 仅 `TestSource/Containers/TArray/Advance`
- Bind 权威: `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp`
- 约定: 上级 `../Organization.md`；单 API 正例在 `../Function/`；Throw 在 `../Exception/`

组合正例，按协议分文件。`@Harness Advance`。本地「做完再回来」标 `@Kind Observe`；给 C++ 对的入口标 `RoundTrip`。默认 `int`，不套类型后缀。`@Tag` = `Containers.TArray.<FileStem>`。

不占 Function L1 分母。不写：存档、嵌套矩阵、种子随机 1000 步、范围 `RemoveAt`。

C++ 侧：`TArrayTest::` 限定，对 `&out` / `&inout` 查写回，对返回的 `TArray<int>` / `int` / `bool` 做相等断言。`ReturnShuffledThenSorted` 与 `ShuffleThenSortInPlace` 的期望是 **Sort(输入)**，不是原顺序。

---

## 文件

| 文件 | Observe | C++ RoundTrip（方向 → 期望） |
|---|---|---|
| `TArraySequence` | `SequenceFromZeroToN` | `&in` 读 `[0..4]`；`&out` / 返回填 `[0..4]`；`&inout` `[0,1,2]` → `[0..4]` |
| `TArrayRestore` | 逆操作 / Shuffle+Sort / Sort 幂等 | `&inout` Insert 再 RemoveAt 写回 `[10,20,30]`；返回同一快照；`ReturnShuffledThenSorted(const&in)` 等于 C++ 自己 Sort 的副本；Append 尾巴再删写回不变 |
| `TArrayTransaction` | Commit / Rollback | `&inout` `[10,20]` → `[20,30]`；返回 `[20,30]`；Rollback 写回仍是输入 |
| `TArrayReplay` | 固定日志 | `&out` / 返回 / `&inout`（先 Empty）都是黄金 `[1,2]` |
| `TArraySidecar` | 双表 RemoveAt | 双 `&inout` 去掉中间；`LookupSidecarId` 返回 int；返回剩 Values / Ids |
| `TArrayCompose` | 先拷再 Add；foreach | `&inout` `[10,20]` → `[10,20,10]`；`SumForEach(const&in)` 对 `[10,20,30]` 返回 `60` |
| `TArrayRoundTrip` | （无 Observe） | 通用载荷 `[1,2,3,4,5]` 四方向 |
