# Canonical AST 被 Runtime registry 反向污染：根因、修复与边界

日期：2026-08-25

## 1. 结论

这次发现的严重问题不是“Canonical AST 天生不能支持多 Module”，也不是
“字段布局偶尔漏算”，而是旧的 Runtime 类型桥接违反了 AST 所有权规则：

> 当前 Module 已经从源码创建了一个有有效 source range 的脚本 `ClassDecl`
> 时，Engine 全局 Runtime registry 中先前 Module 的同名脚本类型，仍可能被
> Sema 当作 host/native 类型命中，并反向改写当前 Module 的 Canonical AST。

结果是 Module A 的 Runtime 产物成为 Module B 源码 AST 的语义来源。这个方向
完全反了：Runtime registry 应当是 CodeGen 成功后的发布目标，以及 native/host
类型的只读 ABI 查询面；它不能覆盖当前源码已经建立的 AST 语义所有权。

现已加上的规则是：

- 有有效源码范围、且不是 `canonical-native-type-view` 的类，是 authored script
  class；其字段、方法、构造器和布局只能来自当前源码/Sema；
- 只有 Sema 为 host/native 类型创建的无源码范围投影，才允许从 Runtime registry
  补充属性、方法、构造器、factory 和 list factory；
- CodeGen 发布阶段遇到另一个仍由 script module 持有的同名 Runtime 类型，继续
  fail-closed 为 `asINVALID_DECLARATION`。这表示“同时共存的跨 Module 同名脚本类型”
  仍未设计完成，不能借这次污染修复假称已经支持。

## 2. 怎样发生

用两个 Module 表示最直观：

```text
Module A source
  class Value { int X; }
          |
          v
Canonical AST A -> CodeGen/Commit
          |
          v
Engine Runtime registry
  key ~= namespace + "Value"
  value = A::Value (existing->module == Module A)

随后构建 Module B：

Module B source
  class Value { int X; }
          |
          v
Parser/Sema creates authored ClassDecl B::Value
  source range = valid
          |
          v
RuntimeTypeBridge resolves "Value"
          |
          +---- incorrectly finds A::Value in Engine registry
          |
          v
old native-intern path treats A::Value as host ABI authority
          |
          v
reclassifies/populates B::Value as canonical-native-type-view
          |
          v
script layout sealing skips/loses B-owned field layout
          |
          v
B::Value::X keeps byteOffset = -1
          |
          v
Canonical CodeGen cannot emit `this.X = ...`
```

原错误路径涉及以下 native projection helper：

- `InternNativeProperties`
- `InternNativeMethods`
- `InternNativeCallablesForType`
- `InternNativeZeroArgCallablesForType`
- `InternNativeListFactoryForType`

这些 helper 本来是为了把已经注册的 C++/host 类型投影成 AST 可查询的只读
声明。例如 `array<int>` 或 UE 绑定值类型可以没有脚本源码声明，但 Sema 仍需要
知道其 properties/methods/behaviours。问题是原实现只确认 Runtime 能解析该名字，
没有确认命中的类型究竟是 native type，还是另一个 script module 的旧类型；也没有
先尊重当前 AST 中已经存在的 authored declaration。

## 3. 为什么表现成 `byteOffset = -1`

失败测试先构建非优化 Module，再用同一 Engine 构建优化 Module；两份脚本原先都
声明：

```angelscript
class NativeDebugLocalValue
{
    int Value;
}
```

第一份构建成功后，Runtime registry 已持有第一个 Module 的
`NativeDebugLocalValue`。第二份构建到 `ValueObject.Value = 7` 时，旧桥接路径错误
命中第一份类型，并污染第二份 AST 的 class ownership/origin。最终构造器赋值没有
获得当前类字段的 sealed layout offset。

为缩短这种问题的定位时间，Canonical CodeGen 的 assignment fail-closed 诊断现在
会打印 function、target stable key/kind/owner、sealed `byteOffset`、Runtime object
和 property count。RED 运行得到：

```text
Canonical CodeGen failed code=-7:
function=NativeDebugLocalValue::NativeDebugLocalValue()
assignment-target=NativeDebugLocalValue::Value
kind=Var owner=NativeDebugLocalValue
byteOffset=-1
runtimeObject=NativeDebugLocalValue runtimeProperties=1
```

这里最有价值的矛盾是：Runtime 明明看到 `runtimeProperties=1`，当前 AST 字段却仍是
`byteOffset=-1`。因此问题不是“Runtime 没有属性”，而是“属性属于旧 Runtime 类型，
当前 authored AST 的字段布局没有成为权威事实”。

RED 证据：

`Saved/Tests/cta-assignment-target-diagnostic/20260825_101547_007_6b84806f`

## 4. 修复原则和实现

`as_sema_expr.cpp` 新增 `IsAuthoredScriptClass(context, classDecl)`，当前判断是：

```text
Decl kind == Class
AND source range begin is valid
AND origin != canonical-native-type-view
```

上述五个 native projection helper 在 Runtime resolve 成功后，先查当前 named type
对应的 AST declaration。如果它已经是 authored script class，就立即返回，不再：

- 调用 `SyncImportedNativeClassKind`；
- 写入 `canonical-native-type-view` origin；
- 从旧 Runtime type 复制 properties/methods/behaviours；
- 以 Runtime type 的 VALUE/REF 分类覆盖源码类型语义。

修复后的权威顺序是：

```text
当前 Module 源码声明
        |
        v
Parser -> Canonical AST -> Sema -> Seal
        |                       |
        |                       +-- authored class layout/members are authoritative
        v
Canonical CodeGen candidate
        |
        v
Commit to Runtime registry

Native/host 类型走旁路：

Engine native registry
        |
        v
range-less canonical-native-type-view
        |
        v
Sema read-only ABI/symbol projection
```

也就是说，Runtime registry 对 authored AST 不再是“回写源”，只对明确的 native
projection 是“读取源”。

## 5. 为什么测试还改成了不同类型名

污染修复后，原 LocalVariables 测试的下一层真实边界暴露出来：同一个 Engine 中，
第一份 script module 的同名类型仍处于 Runtime registry 时，第二份 script module
试图发布同名类型，`RegisterCanonicalScriptTypes()` 会检查
`existing->module != nullptr` 并返回 `asINVALID_DECLARATION`。

这个行为是有意的 fail-closed：当前没有完整的跨 Module 同名脚本类型身份、可见性、
热重载和序列化协议，所以不能把第二个类型静默映射到第一个类型，也不能随意覆盖它。

LocalVariables 测试的目的只是比较优化开/关时的 debug-variable 与 bytecode 行为，
不是验证两个同名脚本类型能同时存在。因此优化 Module 改用了：

- `ENativeDebugLocalEnumOptimized`
- `NativeDebugLocalValueOptimized`
- `NativeDebugLocalReferenceOptimized`

函数名和局部变量名保持一致，使 debug/optimization oracle 不变，同时不再无意要求一个
尚未设计的 module type coexistence 能力。

这不是规避污染 bug：authored-class guard 仍保留并保护 AST 所有权；测试改名只是把
另一个独立的产品边界从该测试中移除。

## 6. 已修复与未支持必须分开

### 已修复

- 旧 Module 的 Runtime script type 不再把当前源码类标成 native view；
- 不再从旧类型向当前 authored AST 注入字段、方法和构造/factory；
- 当前源码类的成员、类型分类和字段布局继续由当前 Sema/Seal 负责；
- 错误赋值路径有稳定、可行动的 ownership/layout 诊断；
- LocalVariables 优化开/关完整测试恢复为 **1/1 PASS**；
- Debug metadata + VariableScope + CanonicalAST Type 组合回归为 **24/24 PASS**。

GREEN 证据：

- `Saved/Build/cta-authored-class-runtime-isolation/20260825_101857_786_f8bc0415`
- `Saved/Tests/cta-local-variables-green6/20260825_102830_035_ec2b9f31`
- `Saved/Tests/cta-debug-scope-type-regressions/20260825_102926_300_dd29a705`

### 仍未支持

下面这种同时存在的类型身份仍未定义：

```text
Module A :: Game::Value
Module B :: Game::Value
```

要真正支持它，至少需要统一设计：

1. 稳定身份：不能只用 `namespace + name`，至少要包含 module identity 和 generation；
2. 源码 name lookup：consumer 在什么条件下看到 A、B 或得到歧义；
3. Runtime registry 索引：一个名字怎样保存多个 module-owned type；
4. ABI/type equality：A::Value 和 B::Value 是不同 nominal type，还是允许结构等价；
5. import 与依赖：如何显式引用某个 provider module 的类型；
6. hot reload：新 generation 如何替换旧 generation，存活对象如何迁移；
7. SaveByteCode/LoadByteCode、StaticJIT、未来 Cache V2 中如何序列化和重定位身份；
8. provider discard 后，consumer/object/type lease 如何维持生命周期。

因此当前最安全且最诚实的产品合同是：

```text
旧 Runtime 类型不得污染新 AST          -> 已修复
两个 Module 同时发布同 namespace/name -> 明确拒绝，尚未设计
native/host 同名投影                   -> 仅通过显式 native-view 路径读取
```

## 7. 严重性判断

这个 bug 的严重级别高，原因不在于当次测试崩在字段 offset，而在于它破坏了
Canonical AST 的核心架构承诺：

- AST 不再是当前源码的 canonical semantic authority；
- 编译结果会依赖同一 Engine 之前构建过什么 Module，造成顺序相关和隐式全局状态；
- debug/optimization 双构建、编辑器热重载、增量构建和未来 cache 恢复都可能得到不同
  语义；
- dump 看起来可能有 class/member，但 ownership/origin/layout 已经来自另一个 Module，
  形成比显式失败更危险的“合法形状、错误事实”；
- 如果不 fail-closed，最坏情况不是编译报错，而是错误 ABI、错误字段访问或跨 generation
  对象布局混用。

当前修复把 authored AST 的优先级恢复了，但完整的跨 Module 类型身份仍应作为独立
OpenSpec 设计，而不是在本次 Canonical AST 切换中临时扩张范围。
