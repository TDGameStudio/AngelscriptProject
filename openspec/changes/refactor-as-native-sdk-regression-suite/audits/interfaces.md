# Public SDK Interfaces

The public interface inventory comes from `AngelscriptRuntime/Core/angelscript.h`. “Contract” means the interface surface/lifecycle is exercised through a real implementation even if no independent test double is appropriate.

| # | Interface | Owner | Coverage kind | Required behavior |
| ---: | --- | --- | --- | --- |
| 1 | `asIScriptEngine` | Engine / Embedding | Behavioral | creation/shutdown, properties, registration, module/context factories, type/function lookup, user data |
| 2 | `asIScriptModule` | Module | Behavioral | sections/build, declarations, globals, types, imports, bind/unbind, bytecode save/load |
| 3 | `asIScriptContext` | Runtime | Behavioral | prepare, arguments/object, execute, suspend/abort/exception, call stack, return values, callbacks |
| 4 | `asIScriptGeneric` | Runtime / Embedding | Behavioral | function/object/auxiliary access, typed argument addresses/type IDs, return address/value |
| 5 | `asIScriptObject` | Runtime | Behavioral | type/property access, address, copy/assignment, refcount, weak reference flag |
| 6 | `asITypeInfo` | TypeSystem | Contract + behavioral | identity, namespace, flags, base/interface/subtype, methods/properties/behaviors, user data |
| 7 | `asIScriptFunction` | TypeSystem / Module | Contract + behavioral | declaration/name/namespace/module, parameters/return, traits, delegate/import metadata, refcount/user data |
| 8 | `asIBinaryStream` | Module | Behavioral | one `FMemoryBinaryStream` drives save/load and short/corrupt stream failures |
| 9 | `asIJITCompiler` | Embedding | Contract | registration, compile/release callbacks, JIT function assignment/clear behavior with deterministic test double |
| 10 | `asIThreadManager` | Engine | Behavioral | manager installation/retrieval and prepare/unprepare thread lifecycle |
| 11 | `asILockableSharedBool` | Engine / Runtime | Behavioral | add/release, lock/unlock, get/set and script-object weak reference integration |
| 12 | `asIStringFactory` | Embedding / Frontend | Behavioral | registration, constant acquire/release, raw data length/copy, duplicate constant identity contract |

## Closure rules

- Each interface must have at least one named test method in the final file map.
- Compile-time inheritance checks alone are insufficient except as a supplemental assertion.
- Test doubles are allowed for host-provided interfaces (`asIJITCompiler`, `asIStringFactory`) but their callbacks must be invoked by a real `asIScriptEngine`.
- `asIScriptObject` remains included even though its full definition appears separately from the other primary interface declarations.
