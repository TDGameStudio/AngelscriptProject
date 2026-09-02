# Canonical Typed AST：namespace 运行时发布闭环（2026-08-23）

## 结论

Canonical Typed AST 的 `namespace` 不再只是一个可被安全拒绝的语法节点。
当 engine 显式选择 `asCOMPILER_PIPELINE_CANONICAL` 时，Canonical Bytecode
CodeGen 现在会按 sealed Decl 的父子树建立正确的 AngelScript runtime
namespace owner，并将下列可发布声明放入该 owner：

- 顶层/namespace 内自由函数与 lambda；
- namespace 内全局变量（包括当前可支持的常量初始化）；
- import 声明；
- 脚本 class/struct，以及它们的方法、构造和析构函数。

它不改变 `asCModule::defaultNamespace` 的既有意义：模块默认 namespace 是
AST 内 namespace 路径的前缀。例如 default namespace 为 `Game` 时，源码
`namespace Tools::Utilities` 会发布到 `Game::Tools::Utilities`。

## 新的所有权解析规则

```text
sealed Canonical Decl tree                         AngelScript runtime
--------------------------                         -------------------
TranslationUnit (default = Game)
  Namespace Tools                         ->       Game::Tools
    Namespace Utilities                   ->       Game::Tools::Utilities
      Var Value                           ->       global Value @ Game::Tools::Utilities
      Function Entry                      ->       function Entry @ Game::Tools::Utilities
      Class Worker                        ->       type Worker @ Game::Tools::Utilities
        Method Run                        ->       Worker::Run (same namespace)
```

`ResolveCanonicalDeclNamespace()` 从具体 Decl 沿 `parent` 向上收集 namespace
segment，再由外到内调用 `asCScriptEngine::AddNameSpace()`。这与旧
`asCBuilder::RegisterTypesFromScript()` 的逐级 namespace 创建语义一致。
AngelScript 的 namespace 是 engine-lifetime 符号而不是 module-owned
artifact；因此它不应被 `asSBytecodeCodeGenArtifact::Abandon()` 当成临时
module 资源销毁。函数、类型、导入和全局变量仍然保留原有的 artifact
transaction rollback。

## 防止静默错误发布

本次没有只把 `asAST_DECL_NAMESPACE` 从拒绝表中删除。那样会导致 namespace
内的函数可能进入 root/default namespace、全局和 class 又被忽略，是比失败
更危险的假成功。CodeGen 同时完成了：

1. `CanonicalDeclIsSupportedForCodeGen()` 接受 `asAST_DECL_NAMESPACE`。
2. `RegisterCanonicalScriptTypes()` 遍历全部 Canonical Decl，而不是仅
   TranslationUnit 的直接 children，并按精确 runtime namespace 去重/注册。
3. 全局变量遍历全部 Decl，但只接受 TranslationUnit 或 namespace 的直接成员，
   因而不会将 class field 当成 global。
4. import 和新建 script function 使用 Decl 的 runtime namespace。
5. host/system global-function 复用增加 namespace 比对，避免 `Tools::F`
   错绑定到 root `F`。
6. class method 所属对象类型查找同时匹配 name 和 namespace，避免同名 class
   跨 namespace 误配。

## 严格验证

测试 `CanonicalNamespaceFunctionBuildsAndPublishesExactRuntimeNamespace` 将
此前允许“成功或 fail-closed”的 namespace 用例改为必须成功，并使用：

```angelscript
namespace Tools::Utilities
{
    const int Value = 41;
    int Entry() { return Value; }
}
```

它断言：

- `Build()==0`，且发布者为 `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`；
- `int Tools::Utilities::Entry()` 可解析并执行为 `41`；
- root `int Entry()` 不存在；
- `Value` 的 `GetGlobalVar()` namespace 精确为 `Tools::Utilities`，并且存储值为 `41`。

测试 `CanonicalNamespaceValueObjectMethodBuildsAndPublishesExactRuntimeNamespace`
在同一个 namespace 内加入 `struct FValue`、构造函数、`Read()` 成员方法，
再从 `Tools::Utilities::Entry()` 构造并调用它。它断言：

- `GetTypeInfoByDecl("Tools::Utilities::FValue")` 可查询，且 type namespace
  精确为 `Tools::Utilities`；
- `FValue::Read()` 是 type-owned method，而不是 root/global function；
- namespace-qualified `Entry()` 实际执行并返回 `41`；
- 发布者仍为 `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`。

### 证据

| Scope | Result | Evidence |
|---|---:|---|
| Runtime/Test recompile + relink | PASS, 14 actions | `Saved/Build/cta-canonical-namespace-green/20260823_103424_917_05fc87a8/RunMetadata.json` |
| Strict nested namespace test | 1/1 PASS | `Saved/Tests/cta-canonical-namespace-green/20260823_103722_272_abdc3cb5/RunMetadata.json` |
| Namespace value-object/method regression recompile + focused test | 4 actions; 1/1 PASS | `Saved/Build/cta-canonical-namespace-value-object-red/20260823_104209_194_e356520a/RunMetadata.json`; `Saved/Tests/cta-canonical-namespace-value-object-red/20260823_104226_467_059fce58/RunMetadata.json` |
| Entire Canonical ProductionCodeGen group after the new regression | 55/55 PASS | `Saved/Tests/cta-canonical-namespace-production-codegen-v2/20260823_104330_885_a1655c1c/RunMetadata.json` |

### 验证环境说明

本 worktree 的 `as_bytecode_codegen.cpp` 与该 ProductionCodeGen test file
处于 untracked 状态。普通 UBT adaptive-unity 增量曾错误报告 `up-to-date`；
关闭 unity 后可确认源码确实被编译，但该模式也暴露了无关的既有问题：
`AngelscriptStaticJITAotMixedBackendPublicationTests.cpp` 在
`AS_WITH_STATIC_JIT_DIAGNOSTICS` 未定义时触发 C4668。这不是本变更引入的
CodeGen 编译错误。随后恢复普通项目构建，实际增量编译首先发现并修正了
`asCMapByName::FindAllUntil` 的参数类型问题，最终 Runtime 与 Test DLL
重新链接成功。

此前的 namespace 测试确实只允许 fail-closed；本次严格版本无法在修改前
获得一个单独的已链接红灯，因为上述非-unity 全目标构建被该独立 StaticJIT
宏错误阻断。最终绿色结论只以真实重编译后的严格 1/1 与完整 55/55 为准，
不将旧二进制或零匹配测试计作验证。

新增的 value-object/method regression 写入时，该共享 worktree 中对应的
namespace CodeGen 实现已经存在，因此它是对既有实现的严格行为刻画，而不是
可回放的 test-first 红灯。它仍通过真实编译、精确 API 查询和 VM 执行来固定
可观察契约；后续新的生产行为必须恢复正常 TDD 的 red → green 顺序。

## 仍未完成的边界

这只闭合了 Canonical Bytecode CodeGen 的 namespace runtime-publication
能力，并不表示整个 AST cutover 已完成：Parser/Sema 仍有 legacy
`asCScriptNode` adapter 依赖，`CompileFunction()` 仍走旧 `asCCompiler`，以及
class/enum/funcdef、异常等更大语义范围仍受 OpenSpec 的 fail-closed 条件约束。
