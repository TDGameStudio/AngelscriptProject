# ASClass 查询语义与加速研究计划

## 背景与目标

当前插件用 `UASClass : UClass` 承载脚本生成类状态，而 Hazelight 引擎分支可以直接在 `UClass` 基类上扩展 `bIsScriptClass`、`ScriptTypePtr` 等字段。插件版本不能修改引擎内存布局，因此所有“一个 `UClass` 是否和 Angelscript 有关”的判断都必须通过 `UASClass` 子类、父类链查询或插件侧外部索引完成。

近期讨论暴露出三个容易混用的语义：

- `direct AS class`：`Class` 自己就是 `UASClass`，可用 `Cast<UASClass>(Class)` 判断。
- `AS-backed class`：`Class` 自己可能是 `UBlueprintGeneratedClass`，但父类链上有最近的 `UASClass`。
- `live AS class`：找到的 `UASClass` 仍持有有效 `ScriptTypePtr`，可以安全进入 AS 类型/VM 路径。

本计划目标是先把这三种语义文档化，再研究并收口 `UASClass` 查询加速方案，避免后续把 `Cast<UASClass>`、`GetFirstASClass()`、`ScriptTypePtr != nullptr` 当成可互换判断。

## 当前事实状态快照

- `UASClass` 定义在 `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h`，继承自 `UClass`，保存 `ScriptTypePtr`、`OwnerScriptEngine`、`bIsScriptClass`、构造函数、defaults 函数和热重载版本链。
- 脚本类创建点在 `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`，使用 `NewObject<UASClass>(..., UASClass::StaticClass(), ...)` 创建类对象，并在 full reload/finalize 流程中设置 `bIsScriptClass = true`。
- `Cast<UASClass>(Class)` 已有多处 automation test 间接固化：`AngelscriptScriptClassStructureTests.cpp`、`AngelscriptScriptClassShapeTests.cpp`、`AngelscriptASClassActorConstructionTests.cpp`、`AngelscriptScriptObjectTypeTests.cpp` 都断言脚本直接生成类可转为 `UASClass`。
- `GetFirstASClass()` 当前实现从传入类本身开始沿 `GetSuperClass()` 向上扫描，返回遇到的第一个 `UASClass`；真实语义是“查找继承链中最近的 AS 类”，不是“第一个注册的 AS 类”或“最顶层 AS 基类”。
- Blueprint child 场景已由 `AngelscriptASClassHelperTests.cpp` 覆盖：脚本父类可 `Cast<UASClass>`，但 Blueprint child 自己不是 `UASClass`，需要 `GetFirstASClass(BlueprintChildClass)` 才能回到脚本父类。
- 热重载或 `DiscardModule` 后，旧 `UASClass` 对象可能仍存在，但 `ScriptTypePtr` 会被清空；因此“找到 `UASClass`”不等于“live script type 可用”。

## 查询语义规范

### Direct AS Class

只回答“当前 `UClass` 对象本身是不是脚本生成类”。

推荐判断：

```cpp
UASClass* DirectASClass = Cast<UASClass>(Class);
```

适用场景：

- 类生成器内部已经拿到脚本生成类。
- 需要访问 `ConstructFunction`、`DefaultsFunction`、`bIsScriptClass` 等 `UASClass` 自身字段。
- 测试断言脚本编译结果确实生成了 `UASClass`。

不适用场景：

- `UObject->GetClass()` 可能返回 Blueprint child class。
- 需要判断“这个类是否由某个 AS 父类支撑”。

### AS-backed Class

回答“当前类或其父类链上是否存在最近的 `UASClass`”。

推荐判断：

```cpp
UASClass* BackingASClass = UASClass::GetFirstASClass(Class);
```

当前更清晰的候选命名：

```cpp
FindNearestASClassInHierarchy(Class)
```

适用场景：

- Blueprint child 继承脚本类：`BP_Child_C -> AMyScriptActor : UASClass -> AActor`。
- 从运行时对象 `Object->GetClass()` 反查 AS 类型。
- Debugger、虚函数解析、`asIScriptObject::GetObjectType()`、脚本属性遍历等需要拿最近脚本类上下文的路径。

### Live AS Class

回答“找到的最近 `UASClass` 是否仍然绑定有效 AS 类型”。

推荐判断：

```cpp
UASClass* ASClass = UASClass::GetFirstASClass(Class);
if (ASClass == nullptr || ASClass->ScriptTypePtr == nullptr)
{
	return;
}
```

适用场景：

- 要读取 `asITypeInfo`、虚函数表、脚本属性信息。
- 要进入 AS VM、JIT、debug value 或 runtime type 路径。
- 需要规避 reload/discard 后旧类仍存在但脚本类型失效的情况。

## 分阶段执行计划

### Phase 1：固定语义与测试证据

- [ ] **P1.1** 新增查询语义文档入口
  - 在本计划中固定三种语义的定义、推荐判断代码、适用场景和误用边界。
  - 重点把 `GetFirstASClass()` 写清为“nearest AS class in superclass hierarchy”，避免继续用“first”这个模糊词解释业务语义。
  - 后续如果需要改 API 名称，先新增 wrapper 保留旧接口，不在同一轮大规模替换调用点。
- [ ] **P1.1** 📦 Git 提交：`[Docs/Plan] Add ASClass lookup semantics plan`

- [ ] **P1.2** 建立现有测试证据表
  - 整理 direct class 断言：脚本编译结果 `Cast<UASClass>` 非空，且 `ScriptTypePtr`、构造函数和 defaults 函数可用。
  - 整理 hierarchy 断言：Blueprint child 不能 direct cast，但 `GetFirstASClass()` 能解析到最近脚本父类。
  - 整理 live 状态断言：reload/discard 后旧类可以仍是 `UASClass`，但 `ScriptTypePtr == nullptr` 表示不可再作为 live script type 使用。
- [ ] **P1.2** 📦 Git 提交：`[Docs/Plan] Record ASClass lookup test evidence`

### Phase 2：设计统一 helper 边界

- [ ] **P2.1** 增加清晰命名的查询 helper
  - 在 `UASClass` 静态 API 层设计兼容 wrapper，而不是让调用点继续自行组合 `Cast<UASClass>`、父链扫描和 `ScriptTypePtr` 检查。
  - 候选 API：`GetDirectASClass(UClass*)`、`FindNearestASClassInHierarchy(UClass*)`、`FindLiveASClassInHierarchy(UClass*)`。
  - 旧 `GetFirstASClass()` 初期保留并转调新 helper，避免一次性破坏调用面。
- [ ] **P2.1** 📦 Git 提交：`[AngelscriptRuntime] Refactor: add explicit ASClass lookup helpers`

- [ ] **P2.2** 补齐 helper 行为测试
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/` 下扩展现有 `AngelscriptASClassHelperTests.cpp`，覆盖 direct AS class、AS->AS 继承、Blueprint child、native-only negative。
  - 增加 live 检查测试时优先复用已有 discard/reload 测试模式，避免为查询 helper 单独搭一套脆弱编译流程。
  - 断言文案必须区分“direct”“nearest in hierarchy”“live script type”，防止测试本身继续制造语义歧义。
- [ ] **P2.2** 📦 Git 提交：`[AngelscriptTest] Test explicit ASClass lookup helpers`

### Phase 3：研究并落地低风险加速

- [ ] **P3.1** 为 direct 查询增加 exact fast path
  - 对只关心当前类本身的场景，提供 O(1) direct helper；实现上仍优先保持 UE 反射安全性，不用未验证的裸内存假设。
  - 如果确认当前不会派生 `UASClass` 子类，可在 helper 内使用更便宜的 exact class 判断；否则继续使用 `Cast<UASClass>`。
  - 这一步不替换 hierarchy 查询调用点，防止 Blueprint child 场景回归。
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptRuntime] Perf: add direct ASClass fast path`

- [ ] **P3.2** 评估父链查询缓存
  - 为 `FindNearestASClassInHierarchy()` 设计 side table 缓存：key 为 `UClass*` 弱引用，value 为最近 `UASClass*` 弱引用，同时缓存 native-only negative result。
  - 第一版失效策略采用保守全量清空，挂接 `OnClassReload`、`OnPostReload`、`DiscardModule` 以及 Editor Blueprint compile/reinstance 相关入口。
  - 缓存不得强持有旧类对象，避免 full reload 后旧类被静态容器延长生命周期。
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptRuntime] Perf: evaluate ASClass hierarchy lookup cache`

- [ ] **P3.3** 用自动化测试验证缓存失效
  - 覆盖缓存命中前后的 direct/Blueprint child/native-only 查询一致性。
  - 覆盖 full reload 后旧缓存不返回过期 live type；`FindNearestASClassInHierarchy()` 可返回类身份，`FindLiveASClassInHierarchy()` 必须检查 `ScriptTypePtr`。
  - 覆盖 module discard 后 live helper 返回 `nullptr`。
- [ ] **P3.3** 📦 Git 提交：`[AngelscriptTest] Test ASClass lookup cache invalidation`

### Phase 4：评估长期加速方向

- [ ] **P4.1** 评估 UObject annotation / 外部字段方案
  - 研究 UE 当前版本可用的 UObject annotation 或类似 sparse side table API，判断是否能把 `UClass -> 最近 UASClass` 作为插件侧外部字段维护。
  - 对比普通 `TMap`：生命周期安全、GC 交互、Editor reinstance 支持、热重载失效成本。
  - 如果 annotation API 不稳定或跨版本代价过高，则保留 `TMap` 缓存方案，不为了模拟 Hazelight 字段访问引入新风险。
- [ ] **P4.1** 📦 Git 提交：`[Docs/Plan] Evaluate UObject annotation for ASClass lookup`

- [ ] **P4.2** 评估热路径绕开查询
  - 针对 `asIScriptObject::GetObjectType()`、脚本虚函数解析、debugger value scope 等路径做采样，确认瓶颈是否真的来自父链查询。
  - 如果 profile 显示查询成本可忽略，不推进对象级 `ScriptTypePtr` 缓存；如果确认为热点，再设计对象构造/重载迁移时的类型缓存刷新协议。
  - 不在没有 profile 证据的前提下改 AS object 内存/生命周期。
- [ ] **P4.2** 📦 Git 提交：`[Docs/Plan] Record ASClass lookup hot-path profiling decision`

## 验收标准

1. 文档明确区分 `direct AS class`、`AS-backed class`、`live AS class`，并给出推荐判断方式。
2. `GetFirstASClass()` 的真实语义被写清为“沿继承链查找最近 `UASClass`”，后续重命名路线不破坏旧 API。
3. 加速方案必须保留 Blueprint child 语义；任何只用 `Cast<UASClass>` 的优化都只能用于 direct 查询。
4. 后续代码实现前必须有 helper 级自动化测试覆盖 direct、AS->AS、Blueprint child、native-only、reload/discard live 状态。
5. 缓存或 annotation 方案必须有明确失效策略，不能强持有旧 `UClass` / `UASClass`。
6. 是否继续推进对象级热路径缓存必须由 profile 数据决定，不以理论推断替代测量。

## 风险与注意事项

### 风险

1. **语义压扁导致 Blueprint child 回归**
   - 风险：把 `GetFirstASClass()` 全局替换成 `Cast<UASClass>` 会把 Blueprint child 错判为非 AS-backed。
   - 缓解：先新增 helper 和测试，按语义逐个调用点迁移。

2. **缓存失效不完整**
   - 风险：hot reload、discard module 或 Blueprint reinstance 后返回过期 `UASClass` 或过期 `ScriptTypePtr`。
   - 缓解：第一版缓存采用保守全量清空，稳定后再考虑局部失效。

3. **把 class identity 和 live script type 混为一谈**
   - 风险：旧类仍可 `Cast<UASClass>`，但 `ScriptTypePtr == nullptr` 时继续进入 AS VM 会产生错误。
   - 缓解：所有 VM/typeinfo 路径使用 live helper 或显式检查 `ScriptTypePtr`。

4. **过早优化**
   - 风险：父链扫描深度通常有限，如果没有真实热点，复杂缓存会增加维护成本。
   - 缓解：低风险 helper 先行，缓存和 annotation 需要测试与 profile 证据支撑。

### 已知行为变化

1. 如果后续新增 `FindNearestASClassInHierarchy()`，旧 `GetFirstASClass()` 的行为不应变化，只作为兼容入口保留。
2. 如果后续新增 live helper，`ScriptTypePtr == nullptr` 的旧 `UASClass` 将被明确视为“非 live”，这可能收紧部分旧调用点的容错行为。
3. 如果后续引入 negative cache，任何新建 Blueprint child 或重新编译 Blueprint class 的路径都必须触发缓存清理，否则 native-only negative result 可能误伤新继承关系。
