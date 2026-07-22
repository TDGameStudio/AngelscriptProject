# Vendored Implementation Units

Source inventory: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_*.cpp` on 2026-07-22. The audit script must fail if this test inventory and the filesystem stop being a one-to-one set.

Disposition meanings:

- `Direct`: tests call classes/functions implemented by this unit.
- `Behavioral`: tests reach the unit through a public SDK behavior whose observable result is asserted.
- `Active backend`: current Win64/MSVC native-call backend plus shared callfunc behavior.
- `Platform N/A`: source is not compiled for the current target; the shared contract is tested, but no false claim is made about that backend.

| # | Implementation unit | Owner | Disposition | Planned coverage |
| ---: | --- | --- | --- | --- |
| 1 | `as_atomic.cpp` | Engine | Direct | `Engine/AngelscriptNativeAtomicTests.cpp`: increment/decrement, assignment, concurrency invariant |
| 2 | `as_builder.cpp` | Compiler | Direct + behavioral | Builder lifecycle/declarations/dependencies/globals/diagnostics; enum-description post-build regression protects committed baseline `b903571` without production-source ownership |
| 3 | `as_bytecode.cpp` | Compiler | Direct | Bytecode instruction/opcode/jump/optimization tests |
| 4 | `as_callfunc.cpp` | Embedding | Active backend | Native global/object/generic calls and calling-convention validation |
| 5 | `as_callfunc_arm.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 6 | `as_callfunc_arm64.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 7 | `as_callfunc_e2k.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 8 | `as_callfunc_mips.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 9 | `as_callfunc_ppc_64.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 10 | `as_callfunc_ppc.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 11 | `as_callfunc_riscv64.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 12 | `as_callfunc_sh4.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 13 | `as_callfunc_x64_gcc.cpp` | Embedding | Platform N/A | Inactive compiler backend; common ABI contract mapped to active-backend tests |
| 14 | `as_callfunc_x64_mingw.cpp` | Embedding | Platform N/A | Inactive compiler backend; common ABI contract mapped to active-backend tests |
| 15 | `as_callfunc_x64_msvc.cpp` | Embedding | Active backend | Win64 MSVC primitive/object/member/generic/native return ABI execution |
| 16 | `as_callfunc_x86.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 17 | `as_callfunc_xenon.cpp` | Embedding | Platform N/A | Inactive backend; common ABI contract mapped to active-backend tests |
| 18 | `as_compiler.cpp` | Compiler | Direct + behavioral | compiler expressions/control flow/conversions/diagnostics and `asCExprContext`/`asCExprValue` state |
| 19 | `as_configgroup.cpp` | TypeSystem | Direct + public contract | config group ownership/removal/reference and access control |
| 20 | `as_context.cpp` | Runtime | Direct + behavioral | prepare/args/execute/suspend/abort/exception/callstack/user data |
| 21 | `as_datatype.cpp` | TypeSystem | Direct | tokens, qualifiers, references, handles-as-fork-rejection, formatting/equality |
| 22 | `as_gc.cpp` | Runtime | Direct + behavioral | detect/enum/release/cycle/statistics/state transitions |
| 23 | `as_generic.cpp` | Runtime | Direct + behavioral | generic argument/address/type/return access through registered host function |
| 24 | `as_globalproperty.cpp` | TypeSystem | Direct + public contract | native global registration, access masks, init pointers, lifetime |
| 25 | `as_memory.cpp` | Engine | Direct + behavioral | allocation hooks, memory manager pools, cleanup and statistics |
| 26 | `as_module.cpp` | Module | Direct + public contract | sections/build/function/type/global/import lookup/discard/bind/unbind |
| 27 | `as_objecttype.cpp` | TypeSystem | Direct + behavioral | properties/methods/behaviors/flags/relationships/fork reference semantics |
| 28 | `as_outputbuffer.cpp` | Compiler | Direct | callback buffering, append/send/clear order and message fidelity |
| 29 | `as_parser.cpp` | Frontend | Direct | scripts/declarations/expressions/statements/errors/fork syntax boundaries |
| 30 | `as_restore.cpp` | Module | Direct + behavioral | writer/reader primitives, module bytecode round-trip and invalid stream errors |
| 31 | `as_scriptcode.cpp` | Frontend | Direct | position/row/column conversion, BOM/line endings, section metadata |
| 32 | `as_scriptengine.cpp` | Engine | Direct + public contract | lifecycle/properties/registration/module/context/type/function/config APIs |
| 33 | `as_scriptfunction.cpp` | TypeSystem | Direct + public contract | declarations/metadata/refcount/traits/parameters/bytecode information |
| 34 | `as_scriptnode.cpp` | Frontend | Direct | tree shape/source range/copy/destroy/deep nesting |
| 35 | `as_scriptobject.cpp` | Runtime | Direct + behavioral | construction/properties/copy/refcount/weak reference/fork runtime behavior |
| 36 | `as_string.cpp` | Frontend | Direct | `asCString`/`asCStringPointer` storage, compare, assignment, ownership |
| 37 | `as_string_util.cpp` | Frontend | Direct | exported compare/scan/UTF-8/UTF-16 encoding and malformed-input boundaries |
| 38 | `as_thread.cpp` | Engine | Direct + behavioral | thread manager prepare/unprepare, TLS state, lockable shared bool behavior |
| 39 | `as_tokenizer.cpp` | Frontend | Direct | complete token families, trivia, BOM, EOF, malformed token recovery |
| 40 | `as_typeinfo.cpp` | TypeSystem | Direct + public contract | base/enum/typedef/funcdef metadata, flags, relationships, user data |
| 41 | `as_variablescope.cpp` | TypeSystem | Direct | nested scopes, declaration lookup, initialization, allocation and variable lifetime |

## Closure rules

- All 41 rows must be present exactly once.
- Rows marked `Direct` require at least one test that names and invokes the concrete implementation owner.
- Rows marked `Behavioral` require execution or externally observable state, not merely successful compilation.
- `Platform N/A` is allowed only for inactive callfunc backends and does not count as executed platform coverage.
- A new vendored `as_*.cpp` file makes the static audit fail until this test inventory and an owner test are updated.
