# Glossary

| term | chosen | rejected | reason |
| --- | --- | --- | --- |
| asSStableKey | keep (pending rename round) | asSTypeDeclKey-only, runtime typeId | 32-byte BLAKE3 of a cacheable canonical identity; equal across processes given the same schema+descriptor; not an Engine or process handle |
| asCCompileOutput | asCCompileOutput | asCCompileOut, kitchen-sink bag | 只对外：UE/ClassGen 描述、诊断等；不含符号 bytecode |
| asCBuilder as producer | Builder fills CompileOutput | new asCCompiler, scatter getters | Round 1 Q3 |
| asCEngineCompileRegistration | asCEngineCompileRegistration | asCCompileRegistration | 延迟把定义装进 asCScriptEngine，并把稳定字节码 Link 成该函数上的 runtime 可执行字节码 |
| two bytecodes on asCScriptFunction | hang both; asCExecutableFunction not public | split ExecutableFunction | Round Q15 A |
| runtime bytecode generation | Registration.Link after Install, eager, before callable | Emit; first Prepare | user asked agent to pin; see findings/runtime-bytecode-timing.md |
| asCDefinitionCompileOutput | asCDefinitionCompileOutput | nested-only, asCMetadataImage | Round 答 Q5 A |
| asCMetadataImage | delete the type | retire-public-only; keep/rename | Round Q8 A reopened: user 不要了 |
| asCModuleDefinitionSet | asCModuleDefinitionSet | asCCompiledDefinitions; asCFrozenDefinitions; asCBuilderDefinitionSet; leftover Image | Q21 A + user name: one compile unit’s TypeInfo/Function/Global until batch Registration; Builder UniquePtr until Take; Module ≠ asCModule |
| compile dependency graph | DAG of asCModuleDefinitionSet; edges non-owning | Image*; Engine-only | Q19 then Q21 |
| asCByteCodeImage | delete the type; stable bodies only on Function | keep as codec/batch; Emit-then-copy | Round 6 Q16 A |
| asCExecutableSnapshot | delete; VM reads Function runtime bytecode | internal lease; keep public | Round 6 Q17 A |
| RunThrough default | through Emit | stop at definitions | Round 6 Q18 A |
| compile then batch register | compile all units engine-free, one Install+Link at the end | register each unit before the next compiles | Round 7 Q20 A |
| Builder two products | TakeModuleDefinitionSet + Get/TakeCompileOutput | CompileOutput owns Set; Set only | Round 9 Q22 A |
| asCDefinitionCompileOutput payload | reuse FAngelscriptModuleDesc / ClassDesc | new SDK-only structs; empty bag | Round 9 Q23 A |
| asCByteCodeEmitter | keep public; RunThrough also calls it | CodeGen rename; Builder-only | Round 9 Q24 A |
| Change ID | angelscript/refactor-sdk-compile-lifecycle | Image-named IDs | user authorized create; convention type-scope-outcome |
