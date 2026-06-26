# Design — improve-as-function-table-incremental-rebuild

## 产物链路（事实）

`AS_FunctionTable_*` 由 C# UBT plugin **`AngelscriptUHTTool`** 在构建期（挂入 UHT 流水线）生成，不在 UE 进程内运行。

- 注册入口：`AngelscriptFunctionTableExporter.cs:22-28` —— `[UhtExporter(Name="AngelscriptFunctionTable", CppFilters=["AS_FunctionTable_*.gen.cpp","AS_FunctionTable_*.cpp"], ModuleName="AngelscriptRuntime")]`。
- 生成主逻辑：`AngelscriptFunctionTableCodeGenerator.cs:103 Generate` → `:304 GenerateModule` → `:1258 CollectEntries`（收集 `BlueprintCallable/Pure`，过滤 `:1806 ShouldGenerate`）→ `:370 CommitOutput`。
- 分片规则：`MaxEntriesPerShard=256`(`:99`)，每模块向上取整。Engine 4054 entries → 16 分片。日志 36 个 = 各模块运行期分片 + cross-module 分片 + link probe。
- 输出目录：`Plugins/Angelscript/Intermediate/Build/<Platform>/<Target>/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_*.gen.cpp`。
- 入编译图机制：`AngelscriptRuntime.Build.cs:92-121` 的 `AddGeneratedFunctionTableWrappers()` 为每模块预声明固定数量 wrapper `.cpp`（Engine=32, UMG=8...），wrapper 内 `#if __has_include(...) #include UE_INLINE_GENERATED_CPP_BY_NAME(...)` 把 `.gen.cpp` inline 进编译。

## 增量护栏（设计本意是增量，非全量）

`AngelscriptUHTTool` 无自建 hash/mtime 增量，依赖 UBT 标准机制：

- `AddExternalDependency(headerPath)`(`:1269`)、`AddExternalDependency(buildCsPath)`(`:942`) 标记输入。
- `CommitOutput(path, contents)`(`:370`) 走 UBT 内容 hash 比对，**内容没变不写盘** → 不触发下游重编。
- 输出确定性：`entries.Sort`(`:316/:330`) 稳定排序、includes 用 `SortedSet`(`:306`)，相同反射输入 → 字节级相同输出。

所以"只改无关 `.cpp` 却全量重编"说明护栏在某环节被击穿。

## 两大嫌疑（按概率）

**嫌疑 B（最高）— 公共头 include 传染**：每个 shard `#include "Core/AngelscriptBinds.h" / "AngelscriptEngine.h" / "FunctionCallers.h"`（`BuildShard:591-593`），三头共 2756 行（`AngelscriptEngine.h` 1645 行）。只要任一公共头被业务改动间接 touch，36 个 shard 的 TU 因 include 链失效全部重编 —— 与 `Note_UBT.md:332`"公共头改动通过 Public include 链传染全 Runtime"吻合。此时 `.gen.cpp` 内容没变，变的是它 include 的头。

**嫌疑 A — codegen 写盘/误删**：
- `DeleteStaleOutputs(:1229)` 每次按 glob 枚举删除不在 live 集的文件；若 live 集判定与 `MakePath` 输出在大小写/分隔符上不匹配，可能误删→重生→时间戳全变→全量重编。
- cross-module 分片走 `Path.Combine(module.OutputDirectory, ...)`(`:394`)，是 `.cpp` 非 `.gen.cpp`，是否同享 `CommitOutput` 护栏需核实。

## 关键不确定点（P0 必须验证）

1. **wrapper inline 的增量判定基于内容 hash 还是 mtime**：wrapper 经 `UE_INLINE_GENERATED_CPP_BY_NAME` inline `.gen.cpp`。若 UBT 按 mtime，则任何重写时间戳（即便内容相同）都触发 wrapper 全量重编 —— 这会让嫌疑 A 的"误删重生"即使内容相同也致命。
2. **cross-module `enabled:false`**：`cross-module-generation-modules.json` 当前关闭，36 个文件主要是运行期分片 + link probe，归因需据此校准。

## P0 诊断实验（修复前置，不可跳过）

在一次"仅改一个无关 `.cpp`（不含反射 UFUNCTION 变化）"的增量构建中采集：

- `AS_FunctionTable_*.gen.cpp` 的 mtime + 内容 hash 在构建前后是否变化；
- UBT `-verbose` 日志中这些 TU 的重编原因（include 失效 vs 文件本身变化）；
- UHT 是否被重新调用（理论上改 `.cpp` 不触发 UHT，因 UHT 只读 `.h`）。

据此分流：
- 文件被重新写盘 → 走嫌疑 A（codegen 侧）。
- 文件未变但 TU 重编 → 走嫌疑 B（include 链）。

## 修复方向

**若 B（include 传染）**：收窄 `BuildShard` 注入的 include —— 拆出稳定、极少改动的最小注册接口头（如 `AngelscriptBindsFwd.h`），让 36 个 shard 只依赖它，避免业务改 `AngelscriptEngine.h` 时全量传染。改 `AngelscriptFunctionTableCodeGenerator.cs:591-593` + 相关头。

**若 A（写盘/误删）**：审查 `DeleteStaleOutputs:1229` 的 `Path.GetFullPath` + 大小写比较(`:1231`)，确保 live 集与写盘路径在 Windows 大小写不敏感下一致；核实 cross-module 分片是否同享 `CommitOutput` 护栏。

两方向可并行验证，以 P0 结论决定主攻。

## 风险

- 本 change 触碰 UHT codegen，回归面是"产物内容必须字节不变、仅改善重编粒度"。任何头部拆分后须确认生成产物与重构前一致（diff `.gen.cpp`）。
- 可能根因是 IDE/UBT 的 `Intermediate/Build` 缓存问题而非代码（文档多处提及），P0 须排除此项。
