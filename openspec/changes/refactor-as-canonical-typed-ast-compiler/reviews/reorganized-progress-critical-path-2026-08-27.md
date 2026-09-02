# `refactor-as-canonical-typed-ast-compiler` 重新梳理后的进展与关键路径（2026-08-27）

## 1. 当前结论

这项 change 不需要推倒重来。长期架构方向是成立的：采用 Clang 风格的 ownership、
Parser/Sema phase boundary、ASTContext、Seal/Verify 与 read-only consumers；不复制 Clang
具体 AST ABI，也不把 daScript 的 mutable multi-pass AST 或 Runtime pointer 直接带入
Public AST/Cache/Provider identity。

本轮重新梳理后，状态应理解为：

- canonical frontend 基础、Public AST V1、SourceManager、Cache default-off containment、
  primary Generate/native-form/diagnostics 骨架已经形成；
- stable type identity、Runtime compatibility、detached relocation 与 module-generation
  lifecycle 已有 focused closure；
- dynamic `typeId` 已从 durable identity 中移出，成为 target Engine/generation 的 late
  public projection；
- change 仍未达到 production cutover：Sema authority、全语言 CodeGen、TypedASTJIT
  canonical consumer、Standalone/default coherence 与 final gates 仍开放。

`tasks.md` 当前是 **82/125 checked，43/125 unchecked**。该数字不能当成 65.6% 的线性
完成度；很多 9.x、10.x、13.x 是同一个 cutover 的重复分层验收。按架构里程碑判断，
当前更接近“基础设施和 Runtime-install boundary 已成熟，semantic/consumer cutover 进入
后半段”，而不是“只剩 43 个互不相关的小任务”。

## 2. 重新整理后的依赖图

```text
A. Sema semantic authority
   4.2-4.6 + 5.2-5.9 + 13.2 + 13.10
                 |
                 v
B. complete sealed-AST Bytecode backend
   9.1 + 9.5-9.7 + 13.6
                 |
        +--------+---------+
        |                  |
        v                  v
C. TypedASTJIT consumer  D. snapshot/publication umbrella
   7.2/7.4/7.5/7.8       3.4/13.8/13.11
        |                  |
        +--------+---------+
                 v
E. Standalone/default coherence + production cutover
   10.1-10.7 + 10.9 + 14.2
                 |
                 v
F. boundary/final gates and documentation
   0.2/0.3 + 11.4 + 14.6 + 12.2/12.4 + 13.12
```

14.3/14.4 已从关键路径中移出：detached relocation failure atomicity 和 generation
ownership 已闭合。它们仍是 B/D 的基础，不再是下一步阻塞。

## 3. 分 section 的任务状态

| Section | Checked | Open | 判断 |
| --- | ---: | ---: | --- |
| 0 AST-first gate | 3 | 2 | protocol 已建立；remaining semantic/cutover cards 与 final AST matrix 未完成 |
| 1 Baselines | 6 | 0 | 完成 |
| 2 SourceManager / AST foundation | 13 | 0 | 完成 |
| 3 Public AST / ownership / Hot Reload | 7 | 1 | focused generation lifecycle 已绿；3.4 umbrella 仍需与最终 production routes 一起签收 |
| 4 Declaration/type Sema | 2 | 5 | 主要开放区 |
| 5 Expression/statement/call/lifetime Sema | 2 | 8 | 最大开放区 |
| 6 Cache default-off containment | 12 | 0 | 本 change 范围内完成；不代表 production restore 已切换 |
| 7 TypedASTJIT canonical migration | 4 | 4 | capture/部分 canonical path 已有，HIR authority removal 未完成 |
| 8 Primary Generate/native form/diagnostics | 9 | 0 | 完成 |
| 9 Canonical Bytecode CodeGen | 5 | 4 | detached install 已成熟，全语言/metadata/differential umbrella 未完成 |
| 10 Production cutover | 1 | 8 | 仍是正式未完成，不应从默认枚举或 broad compatibility pass 推断完成 |
| 11 Standalone/public docs | 4 | 1 | migration notes 尚缺 |
| 12 Final verification | 4 | 2 | focused matrix 与 All 尚未运行到最终状态 |
| 13 Review blockers | 6 | 6 | Sema、CodeGen umbrella、snapshot umbrella、SourceManager truth、adversarial/final gate 仍需关闭 |
| 14 Type identity/install boundary | 4 | 2 | 14.1/14.3/14.4/14.5 完成；14.2 被 Standalone 红灯阻塞，14.6 未运行 |

## 4. Dynamic TypeId 的最终改造方案

### 4.1 不改变 public ABI

AngelScript embedding/generic/reflection 继续公开 `int typeId`。不采用 deterministic eager
ID、hash-derived ID 或全局 pointer identity。这些方案要么破坏现有 ABI，要么仍有碰撞、
注册顺序或跨 Engine 生命周期问题。

### 4.2 四层 identity/binding

```text
snapshot-local asASTTypeRef
    -> complete StableTypeKey
    -> target/profile/native-environment TypeABIKey
    -> immutable generation-local RuntimeTypeBinding
    -> pointer / offset / slot / current public numeric TypeId
```

- `asASTTypeRef` 只能在 owning snapshot 内比较/索引；
- StableTypeKey/TypeABIKey 才能用于 detached artifact、cross-Engine resolve、provider/cache
  fingerprint；
- pointer、property offset、function target、numeric TypeId 只属于 target generation；
- `layoutHash` 只是 accelerator/checksum，完整 ABI fields 才有 equality authority。

### 4.3 Relocation transaction

六类 relocation 现在是：metadata-only、Runtime type target、public numeric-ID projection、
property、function、anonymous list-pattern target。完整 binding table 先 resolve/freeze，
再 patch candidate bytecode，最后 `Commit()` 发布 Engine/module state。

每类都能在 Build 后、patch/Commit 前定点失败，并证明 generation A 的 Engine slots/free
lists、TypeId allocator/map、module inventories、publisher/digest、AST snapshot/key/current
与 Runtime binding fingerprint 不变。Wildcard `?&` 成功路径还验证了 `TYPEID` placeholder
被安装为当前 Engine `FPayload` ID。

### 4.4 Generation lifetime

`asCRuntimeTypeGeneration` 保存 frozen binding table 和 retired module carrier；snapshot
lease 与 external execution lease 共同保活 old generation。A/B exchange 在
`astSnapshotLock` 下原子完成，旧 function 不被就地 retarget，最后一个 A lease 释放后
才销毁 A resources。

这解决了用户指出的“AS TypeId 动态，VM 也跟着动态”的核心坑：VM active operand 可以
动态，但必须由当前 generation 安装；不能让 producer Engine 的数字成为 AST/artifact
事实。

## 5. 当前已经闭合的关键验证

| Gate | Result | Report |
| --- | ---: | --- |
| Type/TypeIdentity/TypeSema | 19/19 PASS | `Saved/Tests/canonical-type-identity-matrix/20260827_004555_981_95d615aa/Report/index.json` |
| Runtime type binding | 10/10 PASS | `Saved/Tests/canonical-runtime-type-binding-final-focused/20260827_010535_347_bb86d11f/Report/index.json` |
| Runtime generation lifecycle | 6/6 PASS | `Saved/Tests/canonical-runtime-type-generation-final/20260827_035434_179_56b4c087/Report/index.json` |
| Six-class relocation transaction | 20/20 PASS | `Saved/Tests/canonical-relocation-matrix-full-transaction/20260827_043434_164_c9fad9ce/Report/index.json` |
| ProductionCodeGen | 111/111 PASS | `Saved/Tests/canonical-relocation-matrix-production-regression/20260827_043507_255_e1b56025/Report/index.json` |
| Module Snapshot | 9/9 PASS | `Saved/Tests/canonical-relocation-matrix-module-snapshot-regression/20260827_043544_787_a2f5b695/Report/index.json` |
| HotReload CanonicalAST | 12/12 PASS | `Saved/Tests/canonical-relocation-matrix-hotreload-regression/20260827_043616_544_f5382824/Report/index.json` |

OpenSpec strict validation 与 parent/submodule `git diff --check` 均通过。换行转换提示来自
worktree 中已有的 LF/CRLF 状态，不是 whitespace error。

## 6. 当前正式红灯与未解决问题

### 6.1 Standalone 8/21

Task 14.2 的 Runtime binding focused 测试本身已绿，但要求的 Standalone gate 仍是
8/21。直接原因是 Engine constructor 当前默认 CANONICAL，而 Standalone baseline 和
array/dictionary/member/HIR/construct/cleanup 等路径尚未具备完整 canonical coverage。

这不是可忽略的“旧测试期待值”：它证明 default cutover 早于 Tasks 4/5/7/9/10 的
完整 closure。14.2、14.6、10.9 和 final gates 因此不能勾选。

### 6.2 Sema authority 仍不完整

仍需把 declaration/type/template/list/import/global、call/receiver/argument/conversion、
structured control、materialization/cleanup/exception/suspend、generated lifecycle 与
debug/source metadata 的裁决完整冻结进 sealed AST。

本轮 relocation fixture 还具体暴露：

- raw canonical parser 显式拒绝 source `@` token；
- registered implicit-handle 的某些局部形式留下 unreachable speculative `DeclRef`；
- native POD local copy/member assignment 的某些形式也留下 unreachable speculative
  `DeclRef`。

这些必须进入对应 AST-first Sema card；不能用 relocation matrix 的绿色结果掩盖。

### 6.3 TypedASTJIT 仍有 HIR dependency

Canonical snapshot capture/部分 migration 已存在，但 eligibility、dependency、resolved
calls、cleanup/exception、recursion/global/import/provider publication 还没有全面转为
canonical visitors。`GetTypedSemanticFunction()` 和 HIR capture 不能提前删除，也不应
增加 AST -> HIR compatibility lowering 继续维护双语义权威。

### 6.4 14.6 与 final gates 未执行

14.6 需要 StaticJIT、Cache default-disabled、Standalone、Runtime/Editor build 与 durable
identity/determinism scans 全部完成。12.2/12.4 还要求更广的 focused matrix 与 All；
二者不能互相替代。

## 7. 推荐执行顺序

1. 恢复 Standalone/default selection coherence，并从失败族反推首批 Sema/CodeGen AST-first
   cards；按 OpenSpec 10.2 的约束，默认选择不能领先于 Tasks 1–9。
2. 按 semantic family 关闭 4.x/5.x/9.x/13.2/13.6，不按零散 opcode 数量推进。每一族先
   sealed-AST RED/GREEN，再 CodeGen/provenance，再 lifecycle/focused regression。
3. 将 TypedASTJIT eligibility/dependency/call/cleanup 等 consumer 全部转到 canonical
   visitors，最后移除 production HIR reads。
4. 完成 3.4/13.8/13.11 umbrella，确认 CompileFunction、Build、Hot Reload、generation、
   restore routes 的同一 snapshot/generation contract。
5. 运行 14.6 boundary gate 与 durable scans；随后运行 10.9 cutover gate。
6. 补 migration docs，运行 12.2 focused matrix、Standalone Debug/Release、12.4 All，再讨论
   archive。未经用户请求不 archive、不创建 legacy VM TypeId follow-up change。

## 8. Review 索引

- 总体架构、Clang/daScript/TypeId 对比：
  `reviews/canonical-ast-architecture-clang-dascript-typeid-2026-08-27.md`；
- Runtime boundary 与 legacy opcode inventory：
  `reviews/type-identity-runtime-boundary-reconciliation-2026-08-27.md`；
- generation ownership/lease/Hot Reload：
  `reviews/canonical-runtime-type-generation-lifecycle-2026-08-27.md`；
- 六类 relocation matrix 与 wildcard TypeId：
  `reviews/canonical-type-relocation-failure-matrix-2026-08-27.md`；
- 本轮逐步实现与历史 RED/GREEN：
  `reviews/implementation-progress-2026-08-27.md`。
