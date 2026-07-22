# Automation ID Migration

The root entry `Angelscript.TestModule.AngelScriptSDK` remains stable. Everything below it adopts a module segment. No legacy aliases are registered.

| Retired prefix family | Replacement prefix family |
| --- | --- |
| `.Atomic` | `.Engine.Atomic` |
| `.Engine` and duplicate root/Smoke cases | `.Engine.Smoke` or `.Engine.Lifecycle` by scenario |
| `.Memory` | `.Engine.Memory` |
| `.Thread` | `.Engine.Threading` |
| `.Tokenizer[.*]` and `.Reference.Tokenizer` | `.Frontend.Tokenizer[.*]` |
| `.Parser[.*]` | `.Frontend.Parser[.*]` |
| `.ScriptNode[.*]` | `.Frontend.ScriptNode[.*]` |
| `.StringUtil` | `.Frontend.StringUtility` |
| `.Builder[.*]` | `.Compiler.Builder[.*]` |
| `.Bytecode[.*]` | `.Compiler.Bytecode[.*]` |
| `.Compile` and raw portions of `.Compiler` | `.Compiler.Core`, `.Compiler.Expressions`, or `.Compiler.ControlFlow` |
| `.OutputBuffer` | `.Compiler.OutputBuffer` |
| `.Execute`, `.Runtime`, `.Stack`, `.Reference.Context` | `.Runtime.ContextExecution`, `.Runtime.ContextControl`, or `.Runtime.ContextStack` |
| `.GC` | `.Runtime.GarbageCollector` |
| raw script-object portions of `.Object`/`.Reference.ScriptClass` | `.Runtime.ScriptObject` or `.Language.*` by behavior |
| `.ScriptModule[.*]` | `.Module.Lifecycle`, `.Module.Lookup`, `.Module.Imports`, `.Module.Namespaces`, `.Module.Sections` |
| `.Restore` and `.Reference.SaveLoad` | `.Module.Restore` or `.Module.SaveLoad` |
| `.ConfigGroup` | `.TypeSystem.ConfigGroup` |
| `.DataType` | `.TypeSystem.DataType` |
| `.GlobalProperty` | `.TypeSystem.GlobalProperty` |
| `.Type` | `.TypeSystem.ObjectType`, `.TypeSystem.TypeInfo`, `.TypeSystem.Enum`, `.TypeSystem.Typedef`, or `.TypeSystem.Funcdef` |
| `.VariableScope` | `.TypeSystem.VariableScope` |
| `.Conversion` | `.Language.Conversion` |
| `.GlobalVar` | `.Language.GlobalVariables` or `.Conformance.ForkGlobals` |
| `.Function` | `.Language.Functions`, `.Language.ControlFlow`, or `.TypeSystem.Funcdef` |
| `.Object`, `.OOP`, `.Reference.ScriptClass` | `.Language.Properties`, `.Language.Constructors`, `.Language.Destructors`, `.Language.Inheritance`, `.Language.References`, or strict `.Conformance.*` |
| `.Operator` | `.Language.Operators` or `.Language.Expressions` |
| `.CallFunc` | `.Embedding.CallFunction` |
| `.CallingConv` | `.Embedding.CallingConvention` |
| `.Register` | `.Embedding.Registration`, `.Embedding.Interfaces`, `.Embedding.StringFactory`, `.Embedding.JITCompiler`, or `.Embedding.ThreadManager` |
| `.Reference.CompilerReject` and `.Reference.ParserErrors` | `.Conformance.ForkRejections` or `.Conformance.Diagnostics` |
| future 2.38 cases (none currently registered) | `.Conformance.UsingNamespace238`, `.MemberInitialization238`, `.DefaultSpecialMembers238`, `.BoolContext238`, `.Lambda238`, `.VariadicFunction238`, and `.TemplateFunction238`, each using the Disabled flags-and-tags registration policy |

## IDs moved outside the SDK root

| Retired SDK prefix | New owning prefix |
| --- | --- |
| `.Compiler` scenarios using `FAngelscriptEngine` | `Angelscript.TestModule.Compiler.ModulePipeline` |
| `.ContextPool` | `Angelscript.TestModule.Engine.ContextPool` |
| `.FunctionCallers` | `Angelscript.TestModule.Engine.FunctionCallers` |
| `.TypeRegistry` | `Angelscript.TestModule.Engine.TypeRegistry` |
| plugin portions of `.Type` / type usage | `Angelscript.TestModule.Engine.TypeUsage` |
| `.DebuggerValue` | `Angelscript.TestModule.Debugger.Value` |
| `.DebugReification` | `Angelscript.TestModule.Debugger.Reification` |
| `.StructCppOps` | `Angelscript.TestModule.Generator.ASStruct.CppOps` |

## Configuration migration

- Keep the group filter matching `Angelscript.TestModule.AngelScriptSDK` from the start.
- Remove filters for `Angelscript.TestModule.AngelScriptSDK.Smoke` and `Angelscript.TestModule.AngelScriptSDK.ASSDK.Smoke`.
- Keep `NativeCore` mapped to the stable root, not a list of nine duplicated domain prefixes.
- Update focused examples/bookmarks to domain prefixes shown above.
