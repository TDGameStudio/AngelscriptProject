# Angelscript 测试约定与宏指南（中文补充）

本文是 `TESTING_GUIDE.md` 的中文补充，重点说明这次修复涉及的生命周期宏边界规则。

## 生命周期宏的真实作用

- `ASTEST_BEGIN_*` 会展开出新的 C++ 作用域，并在其中创建 `FAngelscriptEngineScope`。
- `FULL` / `CLONE` / `NATIVE` 这几类还会在 `BEGIN` 里注册 `ON_SCOPE_EXIT`，把模块回收或 `ShutDownAndRelease()` 绑定到作用域退出。
- `MODULE_CLEAN` 会复用测试模块级 source engine，只清理当前 `BEGIN` / `END` 作用域内新增的 AS module 与 detached generated class 标记；GC 由 pool 分批触发。
- `ASTEST_END_*` 本身主要只是关闭这个由 `BEGIN` 打开的作用域；真正的清理工作来自作用域退出时触发的 RAII 与 `ON_SCOPE_EXIT`。

## `MODULE_CLEAN` 的使用边界

- 优先用于普通 compile-and-execute、绑定 smoke、编译管线正例、不会验证全局引擎销毁语义的测试。
- 不要用于 HotReload 版本链、Debugger 会话、显式 GC 行为、Subsystem/global engine owner、`SHARE_FRESH` 场景或需要断言物理 UObject 回收的测试。
- 如果测试只要求“本测试生成的 module/class 不污染下一测”，优先用 `ASTEST_CREATE_ENGINE_MODULE_CLEAN()` + `ASTEST_BEGIN_MODULE_CLEAN` / `ASTEST_END_MODULE_CLEAN`，不要再默认使用每次强制 GC 的 `SHARE_CLEAN`。
- 需要在模块加载时预热 source engine 时，通过命令行加 `-AngelscriptTestPrewarmEngine`；默认保持 lazy 创建，避免拖慢测试发现和普通 Editor 启动。

## 为什么不要把终结 `return` 写在 `ASTEST_END_*` 前面

- `return true; ASTEST_END_SHARE` 这种写法在预处理后仍然能编译，因为它本质上会变成 `return true; }`。
- 运行时清理依然会发生，因为 `return` 会离开当前作用域并触发析构与 `ON_SCOPE_EXIT`。
- 但源码层面会让 `ASTEST_END_*` 看起来像“死代码”，把本应成对出现的 `BEGIN` / `END` 生命周期边界写得不直观。

## 统一放置规则

- 终结性的成功/失败 `return` 放在 `ASTEST_END_*` 之后。
- 如果最终返回值依赖生命周期作用域里的局部变量，先把结果写入外层变量，再 `ASTEST_END_*`，最后 `return`。

```cpp
bool FExampleTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	int32 Result = 0;
	ASTEST_COMPILE_RUN_INT(Engine,
		"ASExample",
		TEXT("int Run() { return 42; }"),
		TEXT("int Run()"),
		Result);

	bPassed = TestEqual(TEXT("Should return 42"), Result, 42);

	ASTEST_END_FULL
	return bPassed;
}
```

## 参考入口

- 英文完整指南：`TESTING_GUIDE.md`
- 宏说明：`Shared/README_MACROS.md`
- 宏定义：`Shared/AngelscriptTestMacros.h`
