# Angelscript 插件知识库索引

> 本文件是 `Documents/Knowledges/ZH/` 的全局导航入口。
> 所有文档按主题前缀组织，扁平存放于本目录下。

---

---

## Arch_ — 插件总体架构

```
├── Arch_Overview.md                       // 插件总体概览与模块职责
├── Arch_RuntimeLifecycle.md               // Runtime 总控与生命周期
├── Arch_EditorTestDumpCollaboration.md    // Editor / Test / Dump 协作边界
├── Arch_ModuleLoading.md                  // 模块清单与装载关系
├── Arch_ErrorDiagnostics.md               // 报错机制：编译诊断、错误收集与输出链路
└── Arch_UHTToolchain.md                   // UHT 工具链位置与边界
```

## AS_ — AngelScript 引擎内核

```
├── AS_ScriptEngine.md                     // asCScriptEngine 核心架构
├── AS_TypeRegistration.md                 // 类型注册 API
├── AS_Compiler.md                         // asCCompiler 编译流程
├── AS_Parser.md                           // asCParser 解析器
├── AS_ByteCode.md                         // 字节码指令集
├── AS_VirtualMachine.md                   // asCContext 虚拟机
├── AS_GarbageCollector.md                 // GC 策略
├── AS_ObjectLifecycle.md                  // 脚本对象生命周期
├── AS_CallingConventions.md               // 调用约定
├── AS_StringFactory.md                    // 字符串工厂
├── AS_ForkDifferences.md                  // Fork 差异清单
└── AS_LanguageSyntax.md                   // 语言语法速查
```

## Type_ — 类型系统与生成链路

```
├── Type_ClassGeneration.md                // 脚本类生成机制
├── Type_StructGeneration.md               // 脚本结构体生成
├── Type_Preprocessor.md                   // 预处理与模块描述符
├── Type_BindSystem.md                     // Bind 系统与 Native 绑定
├── Type_FunctionCaller.md                 // 函数调用桥
├── Type_FunctionLibrary.md                // FunctionLibrary 暴露面
├── Type_BaseClass.md                      // 脚本基类扩展策略
└── Type_Core.md                           // 类型系统核心
```

## RT_ — 运行时子系统

```
├── RT_HotReload.md                        // 热重载与文件变更链路
├── RT_StaticJIT.md                        // StaticJIT 与执行性能
├── RT_Debugger.md                         // 调试协议集成
├── RT_StateDump.md                        // State Dump 可观测性
├── RT_GlobalState.md                      // 全局状态治理
├── RT_CodeCoverage.md                     // 代码覆盖率统计
├── RT_HashMetadata.md                     // Hash / 元数据辅助
└── RT_ThirdPartyKernel.md                 // ThirdParty 内核集成边界
```

## Test_ — 测试架构

```
├── Test_Layering.md                       // 测试模块总体分层
├── Test_Infrastructure.md                 // 测试基础设施与 Helper
├── Test_TopicClusters.md                  // 主题测试簇映射
└── Test_RuntimeInternal.md                // Runtime 内部测试边界
```

## Syntax_ — 语法机制与实现原理

```
│  ── 关键字与修饰符 ──
├── Syntax_DefaultStatement.md             // default 语句：解析、展开与构造函数映射
├── Syntax_UPROPERTY.md                    // UPROPERTY 修饰符：反射注册与编辑器元数据
├── Syntax_UFUNCTION.md                    // UFUNCTION 修饰符：BlueprintOverride / Event / Pure
├── Syntax_DefaultComponent.md             // DefaultComponent / Attach / RootComponent 组件声明
├── Syntax_DelegateEvent.md                // delegate / event 关键字：签名声明与多播机制
├── Syntax_AccessSpecifiers.md             // access 自定义访问修饰符
├── Syntax_PropertyAccessor.md             // property 关键字：Get/Set 访问器语法糖
├── Syntax_Mixin.md                        // mixin 关键字：非侵入式扩展方法
├── Syntax_FString.md                      // f-string 格式化：编译期展开与格式说明符
│
│  ── 容器类型 ──
├── Syntax_TArray.md                       // TArray<T>：动态数组，FScriptArray 桥接 + 模板实例化
├── Syntax_TMap.md                         // TMap<K, V>：哈希映射，键类型约束与 GenericContainer 优化
├── Syntax_TSet.md                         // TSet<T>：哈希集合，与 TMap 共享 KeyFuncs 机制
├── Syntax_TOptional.md                    // TOptional<T>：可选值包装，IsSet / Get / Reset 语义
│
│  ── 智能指针与引用包装 ──
├── Syntax_TSubclassOf.md                  // TSubclassOf<T>：UClass 类型安全引用，蓝图 ClassPicker 集成
├── Syntax_TWeakObjectPtr.md               // TWeakObjectPtr<T>：UObject 弱引用，IsValid / Get 语义
├── Syntax_TSoftObjectPtr.md               // TSoftObjectPtr / TSoftClassPtr：软引用资源/类，AssetManager 集成
│
│  ── 类型擦除 ──
└── Syntax_FInstancedStruct.md             // FInstancedStruct：类型擦除 struct，StructUtils 桥接
```

## Diff_ — 与参考实现的差异分析

```
├── Diff_HazelightDefaultStatement.md       // default 语句实现与 Hazelight 引擎的偏离分析
├── Diff_HazelightInsightsToBorrow.md       // 全插件视角：Hazelight 中可借鉴的设计点汇总
└── Diff_VerseArchitecture.md               // Verse vs AS 插件：语言/编译器/VM/反射/GC/并发架构差异 + 优劣判断与选型指南 + 优劣判断与选型指南
```

> 注：Diff_ 仅做客观差异比对与处理决策记录；可执行的补足任务对应到 `Documents/Plans/Plan_*HazelightParity.md` 系列。

## Guide_ — 实践指南

```
│  ── 入门 ──
├── Guide_QuickStart.md                    // 环境搭建与第一个 AS 脚本
├── Guide_SyntaxFeatures.md                // AS 语法特色速览
│
│  ── 核心运行时 ──
├── Guide_RuntimeLifecycle.md              // 脚本引擎初始化、编译、执行全流程
├── Guide_ClassBinding.md                  // C++ 类/枚举/委托绑定暴露给 AS
├── Guide_ScriptMixin.md                   // ScriptMixin 非侵入式方法注入
├── Guide_DelegateSystem.md                // 单播/多播委托声明与使用
│
│  ── 编辑器与工具链 ──
├── Guide_EditorExtension.md               // 编辑器菜单扩展与函数分类管理
├── Guide_UHTToolchain.md                  // UHT 工具链使用与注意事项
│
│  ── 测试与质量 ──
├── Guide_TestWriting.md                   // 集成测试编写：状态管理与断言
├── Guide_CodeCoverage.md                  // 代码覆盖率：配置、运行、报告解读
│
│  ── 调试 ──
├── Guide_Debugging.md                     // 远程调试：断点、调用栈、多客户端
├── Guide_DumpDiagnostics.md               // Dump 诊断：崩溃分析与状态导出
│
│  ── 功能模块 ──
├── Guide_SubsystemUsage.md                // 四大子系统 (World/Engine/LP/GI)
├── Guide_GASIntegration.md                // GAS 游戏能力系统接入
├── Guide_UIManagement.md                  // UI 管理：视口覆盖层与异步加载
├── Guide_InputSystem.md                   // 增强输入系统与 AS 集成
└── Guide_NetworkSimulation.md             // 网络模拟 (FakeNetDriver) 测试调试
```

## Note_ — 零散笔记

```
├── Note_UBT.md                            // UBT 构建约束
├── Note_InterfaceBinding.md               // 接口绑定现状
├── Note_InternalsEngineFactory.md         // Internals 引擎工厂分析
├── Note_ScreenshotTestHelper.md           // 截图测试 Helper
└── Note_CQTest.md                         // CQTest 测试框架使用笔记
```
