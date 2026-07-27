# Engine、TypeSystem 与 Embedding 逐产品断言深度审计

## 结论

本轮从 `catalogs/coverage-products.psd1` 精确枚举了 Owner 位于
`Engine/`、`TypeSystem/`、`Embedding/` 的全部 62 个产品，并打开每个产品指定的
`文件 | 测试类 | TEST_METHOD` 进行逐项核对。

| Theme | 产品数 | Complete | ChangeRequired | Deferred |
| --- | ---: | ---: | ---: | ---: |
| Engine | 36 | 23 | 11 | 2 |
| TypeSystem | 17 | 8 | 9 | 0 |
| Embedding | 9 | 0 | 9 | 0 |
| 合计 | 62 | 31 | 29 | 2 |

逐产品结果、精确源码范围、缺失 oracle 和后续动作记录在
`assertion-depth-engine-typesystem-embedding-review.csv`。

## 审计口径

本轮没有按断言数量判定深度，而是按产品 `Expected` 的每项行为与声明的 Evidence
检查是否存在可失败、可定位的实际 oracle：

- `Compile`：必须检查构建/编译结果或精确发布结果，只有生成源码和调用 Build 不算。
- `Diagnostic`：必须检查拒绝结果、错误边界或拥有诊断；只有编译失败不自动算完整诊断。
- `Metadata`：必须查询并比较精确 ID、声明、所有者、标志、索引或回调元数据。
- `Runtime`：必须执行目标行为并比较返回值、写回值、副作用或分派结果；compile-only
  不能替代 Runtime。
- `Debug`：必须检查调试信息、行号、调用栈或调试 API 结果。
- `Bytecode`：必须检查字节码发布、内容边界或序列化结果。
- `Lifecycle`：必须观察状态转换、引用计数、创建/销毁回调或阶段计数，只有局部对象存在
  不算生命周期证据。
- `Cleanup`：必须观察释放后的计数、空状态、模块消失、回调或引用基线；RAII、
  `ON_SCOPE_EXIT` 和调用 `Destroy/Release` 本身不单独证明 Cleanup。
- `Isolation`：必须有第二所有者、控制对象、跨 cell 不污染或恢复基线的断言；案例独占
  Engine guard 本身不算 Isolation。
- `SaveLoad`：必须覆盖保存和加载两端，并验证加载后的身份或行为。
- `Recovery`：必须在失败后执行修正后的同名/同状态操作并验证恢复结果。

## 明确缺口类别

在声明但未被实际 oracle 支持的 Evidence 中：

| 缺口 | 产品数 | 主要表现 |
| --- | ---: | --- |
| Cleanup | 21 | 只有 scope guard、RAII 或 Release/Destroy 调用，没有释放后状态、计数或回调 |
| Isolation | 11 | 只有案例局部状态，没有独立 owner/control 或跨 cell 不污染断言 |
| Lifecycle | 7 | 有对象或上下文，但没有创建、转换、引用或销毁的可观察计数 |
| Metadata | 3 | 只检查注册成功，没有查询精确声明或 ABI/所有者元数据 |
| Runtime | 3 | JIT 只验证编译回调；Delegate 正向执行因 fork 崩溃被推迟 |
| Diagnostic | 2 | Expected 含拒绝/异常面，但精确 Owner 没有执行该路径 |

这些主题当前没有产品声明 `Debug` 或 `Recovery`。`SaveLoad` 也没有被 catalog 声明，
但 `TYPE-TYPEDEF-BYTECODE-RUNTIME` 已实际执行并断言 `SaveByteCode`、`LoadByteCode`
以及独立加载引擎上的运行结果，因此 CSV 将 `SaveLoad` 记录为
“实际观察到但 catalog 未声明”的证据。

## 需要优先调整的产品

### Embedding Owner 与 Expected 范围不一致

以下产品不是单个小 oracle 缺失，而是精确 Owner 只覆盖了 Expected 的一个子集：

- `EMBED-NATIVE-CALL-ABI-SHAPES`：Owner 只执行四个 `int` 参数的 `AddFour`；
  Expected 中的 double、int64、bool、out、嵌套调用和重复 void 副作用没有进入该方法。
- `EMBED-CALLING-CONVENTION-DISPATCH`：Owner 只执行一个 CDecl 全局函数；
  generic、thiscall 和 CDecl object-last 不在该方法中。
- `EMBED-GLOBAL-CALLBACK-ARGUMENT-SHAPES`：Owner 只执行零参数回调及一个直接 Context
  清理路径；一参、两参、混合宽度和 float-property-aware 形状不在该方法中。
- `EMBED-GLOBAL-REGISTRATION-SURFACES`：Owner 只测试全局函数；
  Expected 中的全局属性索引、类型、可变性、地址和写回没有进入该方法。
- `EMBED-OBJECT-REGISTRATION-CONTRACTS`：Owner 只测试 `Counter` POD；
  double wrapper 和缺失 automatic caller 的异常/拒绝路径没有进入该方法。

这些产品应选择其一：把 Expected 的所有行为放入精确 Owner，或拆成多个具有真实 Owner
和独立 Evidence 的产品。不能依赖同文件内其他未被 Owner 指向的方法补足。

### Compile 不能替代 Runtime

- `EMBED-JIT-INSTALL-COMPILE-LIFECYCLE` 已充分验证 JIT compiler 安装、替换、清除和
  编译回调路由，但没有执行三个阶段的 `Entry`。
- `EMBED-JIT-FAILURE-RELEASE-BOUNDARY` 验证了失败/发布/显式释放边界，但没有执行
  被保留用于解释执行的模块。

两者均应增加精确返回值执行 oracle，或者从声明 Evidence 中移除 Runtime。

### Cleanup 声明过宽

TypeSystem 中多项 metadata/runtime 产品仅依赖 Engine 或 Module 的作用域清理：

- `TYPE-CONFIG-GROUP-STORAGE-ONLY`
- `TYPE-DATATYPE-HANDLE-CONTRACT`
- `TYPE-DEFAULT-TRAIT-METADATA-RUNTIME`
- `TYPE-ENUM-REGISTRATION-RUNTIME`
- `TYPE-GLOBAL-PROPERTY-ACCESS-SHAPES`
- `TYPE-TYPEDEF-BYTECODE-RUNTIME`
- `TYPE-ENGINE-PRIMITIVE-TYPEID-ROUNDTRIP`
- `TYPE-TYPEINFO-OBJECT-STRUCTURE`
- `TYPE-SCRIPTFUNCTION-METADATA-KINDS`

应增加模块消失、引用基线、回调计数或清理后空状态等 oracle；否则应收窄 Evidence。

### 当前 fork 限制

两个 Engine 产品记录为 `Deferred`：

- `ENG-OBJECT-SERVICE-DELEGATE-LIFECYCLE`：无效输入路径已有断言，但有效 Delegate
  的参数写入、顶层执行和 shutdown GC reporting 在当前 fork 会分别触发已知崩溃，
  所以 Runtime/Lifecycle/Cleanup 正向路径尚未执行。
- `ENG-OBJECT-SERVICE-REFCAST-CONTRACT`：安全路径的转换和引用平衡完整；runtime-type
  mismatch 与跨 Engine TypeInfo 两个边界因当前 fork 在分派前不验证不变量而只打印、
  未执行。

这些限制不是删除测试或降低目标的理由。修复对应 fork API 后，应启用现有记录的边界，
并把 Deferred 改为 Complete。

## 验证边界

本轮仅进行只读源码审计，并新增本摘要与逐产品 CSV：

- 没有修改任何测试代码或 catalog。
- 没有修改 `tasks.md`、progress 或其他状态记录。
- 没有运行会重写 catalog/audit 的全局脚本。
- 没有执行构建或自动化测试。

CSV 已核对：

- 62 行产品记录，无重复 ProductId。
- 与 `coverage-products.psd1` 的目标产品集合一一对应，无遗漏、无额外产品。
- Theme、Owner、EvidenceDeclared 与 catalog 完全一致。
