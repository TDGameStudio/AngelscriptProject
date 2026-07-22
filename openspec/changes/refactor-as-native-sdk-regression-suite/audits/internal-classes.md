# Internal Concrete Classes

The scope is the 36 concrete `asC*` classes with out-of-line implementation logic identified in the current fork. `Existing` means the declaration already has usable DLL visibility; `Add export` is the approved set that receives `ANGELSCRIPTRUNTIME_API` plus a `[UE++]` test-visibility comment.

| # | Concrete class | Visibility action | Owner | Direct coverage theme |
| ---: | --- | --- | --- | --- |
| 1 | `asCAtomic` | Add export | Engine | atomic arithmetic and concurrent balance |
| 2 | `asCBuilder` | Existing | Compiler | build phases, symbols, dependencies, diagnostics, cleanup |
| 3 | `asCByteCode` | Existing | Compiler | instruction list, labels, finalize, optimize |
| 4 | `asCByteInstruction` | Add export | Compiler | opcode fields, stack delta, argument storage, links |
| 5 | `asCCompiler` | Existing | Compiler | expression/statement compilation and bytecode result |
| 6 | `asCConfigGroup` | Add export | TypeSystem | ownership/reference/removal/access |
| 7 | `asCContext` | Existing | Runtime | lifecycle, stack, exception, suspension, abort |
| 8 | `asCDataType` | Existing | TypeSystem | construction, token conversion, modifiers, equality |
| 9 | `asCEnumType` | Add export | TypeSystem | enum identity, values, flags, inheritance contract |
| 10 | `asCExprContext` | Add export | Compiler | expression state merge/cleanup/type propagation |
| 11 | `asCExprValue` | Add export | Compiler | value/register/reference state and cleanup |
| 12 | `asCFuncdefType` | Add export | TypeSystem | funcdef signature and metadata |
| 13 | `asCGarbageCollector` | Existing | Runtime | GC object lifecycle, detection and statistics |
| 14 | `asCGeneric` | Existing | Runtime | generic call argument/return inspection |
| 15 | `asCGlobalProperty` | Existing | TypeSystem | property address/type/access/refcount |
| 16 | `asCLockableSharedBool` | Add export | Engine | lock/get/set/refcount |
| 17 | `asCMemoryMgr` | Existing | Engine | allocator/pool lifecycle |
| 18 | `asCModule` | Existing | Module | section/build/lookup/import/global/type lifecycle |
| 19 | `asCObjectType` | Existing | TypeSystem | methods/properties/behaviors/subtyping |
| 20 | `asCOutputBuffer` | Add export | Compiler | buffer/callback ordering and clearing |
| 21 | `asCParser` | Existing | Frontend | script/declaration/expression/statement parsing |
| 22 | `asCReader` | Existing | Module | bytecode primitive/object reads and errors |
| 23 | `asCScriptCode` | Existing | Frontend | position and source metadata conversion |
| 24 | `asCScriptEngine` | Existing | Engine | lifecycle/properties/registration/factories |
| 25 | `asCScriptFunction` | Existing | TypeSystem | declaration/parameters/traits/metadata/refcount |
| 26 | `asCScriptNode` | Existing | Frontend | tree/copy/range/destroy |
| 27 | `asCScriptObject` | Existing | Runtime | construct/copy/property/ref/weak-ref behavior |
| 28 | `asCString` | Existing | Frontend | storage/compare/assignment/formatting |
| 29 | `asCStringPointer` | Add export | Frontend | pointer ownership/copy/assignment/equality |
| 30 | `asCThreadLocalData` | Add export | Engine | active/primary context and cleanup state |
| 31 | `asCThreadManager` | Add export | Engine | thread prepare/unprepare and TLS lookup |
| 32 | `asCTokenizer` | Existing | Frontend | direct token-family tests |
| 33 | `asCTypedefType` | Add export | TypeSystem | typedef identity/underlying type/flags |
| 34 | `asCTypeInfo` | Existing | TypeSystem | names/namespaces/base/flags/user data |
| 35 | `asCVariableScope` | Add export | TypeSystem | scope nesting/variable lookup/allocation state |
| 36 | `asCWriter` | Existing | Module | bytecode primitive/object writes and errors |

## Export closure

The exact add-export set is: `asCAtomic`, `asCByteInstruction`, `asCConfigGroup`, `asCEnumType`, `asCExprContext`, `asCExprValue`, `asCFuncdefType`, `asCLockableSharedBool`, `asCOutputBuffer`, `asCStringPointer`, `asCThreadLocalData`, `asCThreadManager`, `asCTypedefType`, and `asCVariableScope`.

No other internal class receives visibility as part of this change. Direct tests must include the real owning header and must not replace the class with a local look-alike.
