# Multithread compile vs multi-module type dependencies

The user asked how parallelism works today, how module type deps are handled, and what happens if later types depend on earlier ones with no Engine.

## Two different graphs, two different “parallel”s

```text
轴 1 — 一个 asCBuilder 里面
  词法 / 预处理 / 声明解析     单线程（WorkerCount 传了但 ResolveDeclarations 不用）
  默认参数 initializer         单线程，先做完
  函数体 AnalyzeBodies         唯一真多线程：min(WorkerCount, 函数数) 条 std::thread，stride 分函数
  Emit                         单线程
  Registration                 单线程，对着一个 Engine

轴 2 — 多个模块 / 多次 Builder
  SDK：调用方按依赖顺序 new 下一个 asCBuilder
       Options.Dependencies = 已经 Frozen 的别人的 Image
  宿主 CompileModules：ImportedModules + CompilationQueue 波浪
       Stage1–3 已故意失败；ParallelFor 里写死 asNOT_SUPPORTED
```

There is no SDK scheduler that compiles independent modules on a thread pool. `WorkerCount` is body analysis inside one session.

## How a later module sees an earlier type (today, no Engine)

Image must be Frozen before it can be a dependency. The dependent Builder never needs an Engine:

```text
Builder A（无 Engine）
 └─ Freeze Image A                    // 真 TypeInfo/Function，engine == nullptr，TypeId == -1

Builder B
 └─ Options.Dependencies = { Image A }
    └─ Session.AddExternalDefinitions    // 闭包登记 ExternalTypes
         └─ sema / Emit 可以写 A::T
```

`asCMetadataImage::AddDependency` rejects unfrozen images and cycles. That *is* the compile-time type library. Putting A into an Engine is not what makes B compile.

Host `ImportedModules` is a second, Engine-tied module graph (active or currently compiling). It is not the SDK Image DAG. Stage1 currently errors out before that path does real work.

## The “compile A, put in Engine, then compile B” idea

That works **if an Engine exists**, and it is how **Link/run** must work (runtime bytecode needs Engine-local pointers). It is **not** required for **compile/Emit**:

```text
有 Engine（可选，为了跑）
  A 编完 → Registration.Install(+Link) → Engine 上有 A
  B 编的时候也可以从 Engine 读 A 的 TypeInfo

无 Engine（延迟注册的本意）
  A 编完 → pending TypeInfo 留在 Builder A（收缩后）/ Frozen Image（现在）
  B 编 → 不拥有地引用那些 TypeInfo
  以后某个 Engine 再 Registration A 然后 B（或一批一起装）
```

Without Engine you still have a type graph: the previous compile’s objects. You do not invent a fake Engine just so B can name A::T.

Independent modules (no edges) could in principle be two Builders at once. Today they usually share one `asCTypeContext` / identity registry so keys stay in one world; Intern is not a documented multi-Builder lock. Body workers inside one session are the only supported parallel. Do not treat “wave of unrelated modules on a thread pool” as current behavior.

## After the settled shrink

Same two axes. Dependencies become non-owning TypeInfo*/Function* instead of Image*. RunThrough includes Emit. Registration still does not own workers and still does not Emit.

```text
无 Engine
  波次 0：没有入边的编译单元（可串行；并行不是现成能力）
    └─ 每个 Builder：内部 body 多线程 → Function 上已有稳定码
  波次 1：依赖波次 0 的 TypeInfo*（不拥有，也不进 Engine）

有 Engine（之后，要跑）
  Registration 按同样 DAG 或整批 Install+Link
```

Host module-wave scheduling stays out of this SDK shrink.
