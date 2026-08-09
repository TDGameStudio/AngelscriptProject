# Add-on and license audit — standalone compiler task 1.4

Audit scope: read-only audit completed 2026-07-31. This report covers the pinned local reference checkout and the maintained Unreal AngelScript fork only. It does not import, alter, compile, or copy third-party source.

## Conclusion

All four requested official add-ons are available locally. Their normal registration entry points select generic registration when the engine reports AS_MAX_PORTABILITY, so they are viable import candidates for the planned generic-only profile.

They are not drop-in sources. The 2.38 scriptstdstring implementation calls a newer public API which the maintained 2.33-based fork does not expose. Further, upstream allocation and loop behaviour do not meet the planned standalone allocation-accounting and cancellation contracts without explicit adaptations. No portable standalone target exists yet, so this is source evidence rather than an end-to-end build proof.

## 1. Requested add-ons and exact local paths

| Add-on | Reference files | Finding |
| --- | --- | --- |
| scriptstdstring | Reference/angelscript-v2.38.0/sdk/add_on/scriptstdstring/scriptstdstring.h; scriptstdstring.cpp; scriptstdstring_utils.cpp | Present. The utils source depends on scriptarray. |
| scriptarray | Reference/angelscript-v2.38.0/sdk/add_on/scriptarray/scriptarray.h; scriptarray.cpp | Present. |
| scriptdictionary | Reference/angelscript-v2.38.0/sdk/add_on/scriptdictionary/scriptdictionary.h; scriptdictionary.cpp | Present. |
| scriptmath | Reference/angelscript-v2.38.0/sdk/add_on/scriptmath/scriptmath.h; scriptmath.cpp | Present. |

The maintained fork has no copies of these add-ons. Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript contains the maintained core source only.

A sibling scriptmathcomplex.h/.cpp is present in the reference but is neither requested nor suitable for this profile: its RegisterScriptMathComplex implementation asserts when AS_MAX_PORTABILITY is enabled because generic registration is unimplemented.

## 2. Local upstream, revision, and license evidence

### Provenance

- Local reference checkout: Reference/angelscript-v2.38.0.
- Git remote recorded locally: git@github.com:anjo76/angelscript.git.
- Exact checkout revision: 0601da029d846a658bf23f2888e953a45a94450a, abbreviated 0601da0, tagged v2.38.0.
- Commit metadata: 2025-08-12T14:56:23-03:00, Create README.md.
- Reference/sdk/angelscript/include/angelscript.h defines ANGELSCRIPT_VERSION as 23800 and ANGELSCRIPT_VERSION_STRING as 2.38.0 at lines 61-62.

### License

The reference checkout has no separate top-level LICENSE file. Its canonical local AngelScript notice is at Reference/angelscript-v2.38.0/sdk/angelscript/include/angelscript.h lines 1-28: Copyright (c) 2003-2025 Andreas Jonsson, an as-is warranty disclaimer, and the three zlib-style conditions: do not misrepresent origin, plainly mark altered versions, and do not remove or alter the notice.

The requested add-on source files begin with includes rather than the notice. An import must carry the notice alongside them; preserving only the file bodies would not be adequate provenance.

Repository convention is compatible but distinct. Plugins/Angelscript/LICENSE.md licenses plugin material under MIT and separately reproduces the AngelScript zlib notice for its ThirdParty/angelscript core. Standalone add-on copies must remain identified as AngelScript/zlib material; they are not relicensed by the plugin MIT license.

Recommended immutable import inventory, calculated from the local pinned files:

| Source file | SHA-256 |
| --- | --- |
| scriptstdstring/scriptstdstring.cpp | 83397E22AF59DD2BCE2854BEB0825F56DE9FF60658BDD3A2AC55784DE7B2A42E |
| scriptstdstring/scriptstdstring.h | 56D67F8D84477841EDF63D1F2E65BABC0457905474574596FA071A5AA9FF75B0 |
| scriptstdstring/scriptstdstring_utils.cpp | 8E48DB8C5F9E17DA8DF1AA52C4FE1E5AA668FCD5B23FC7BA88A1962EA069660E |
| scriptarray/scriptarray.cpp | 953C6C389CC0DDC150A730538A5980F3BCDB9366F9D4AF98AF93CBEEF9EDF917 |
| scriptarray/scriptarray.h | EB83C6117702F54E65156536CDE0EC8AF2DB836415BEFF485A2DE9FF2592018B |
| scriptdictionary/scriptdictionary.cpp | 07E242CB4F08B9BB1F1949A39B618AA461CC2AD8B0DF86ECBB4713A3C8F7D760 |
| scriptdictionary/scriptdictionary.h | E0662AE1BBF5315F5FF06ABAAF60A31E172A5F37E3B65243D3757A6CF3978CBC |
| scriptmath/scriptmath.cpp | BEBCCAC9E179C3BB72B9A64EB384F22C9E1B4A13B42D99C1AFA97AF48119CB0F |
| scriptmath/scriptmath.h | 26850EEC4C7A319D551D0356BA2D2D197BE0C16D1A336B590570F67BDB851CE9 |

## 3. Dependencies and AS_MAX_PORTABILITY

| Add-on | Direct source dependencies | Generic-mode result |
| --- | --- | --- |
| scriptstdstring | The maintained angelscript.h; C++ string, streams, C string/stdio/stdlib, locale, regex, and map/unordered_map. scriptstdstring_utils.cpp includes ../scriptarray/scriptarray.h. | RegisterStdString selects RegisterStdString_Generic when the option string contains AS_MAX_PORTABILITY, at lines 1613-1618. RegisterStdStringUtils uses asCALL_GENERIC at lines 114-126. Register string before its utils, and register array before the utils. |
| scriptarray | The maintained angelscript.h; C++ new, C allocation/string/stdio headers, string, and algorithm. | RegisterScriptArray selects RegisterScriptArray_Generic under AS_MAX_PORTABILITY at lines 272-277. It can register array<T> as the default array type. |
| scriptdictionary | The maintained angelscript.h; string plus unordered_map for C++11 or map otherwise. Its .cpp includes ../scriptarray/scriptarray.h and its header says string must be registered first. | RegisterScriptDictionary selects RegisterScriptDictionary_Generic at lines 1253-1258. Registration follows string and array. |
| scriptmath | The maintained angelscript.h; C math, float, and string headers, plus C++ math only in a Borland branch. | RegisterScriptMath selects RegisterScriptMath_Generic at lines 361-366. It has no dependency on the other requested add-ons. |

The requested four sources therefore contain generic registration paths and are designed to compile and register in maximum-portability mode. This remains conditional source evidence, not a completed standalone build: the no-UE portable maintained core and its CMake target do not yet exist.

## 4. Maintained-fork API compatibility and adaptations

### Confirmed public API break

The maintained public header is Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h. At line 800 it exposes the older method:

    virtual int GetStringFactoryReturnTypeId(asDWORD *flags = 0) const = 0;

The v2.38 reference header instead introduces GetStringFactory at line 713 and retains GetStringFactoryReturnTypeId only behind AS_DEPRECATED. The reference scriptstdstring.cpp calls the newer no-argument GetStringFactory at lines 702 and 782. The maintained header has no such member, so unchanged source does not compile against the maintained fork.

Required reviewed delta: replace both no-argument calls with GetStringFactoryReturnTypeId(). Both calls seek the registered string type ID, so this is the old API's direct semantic equivalent. Record both replacements in the imported-source delta ledger.

Do not copy Reference/sdk/angelscript/include/angelscript.h and do not put the reference include directory ahead of the maintained header. The add-on includes of angelscript.h must resolve to the maintained public header. Otherwise the compilation unit advertises upstream 23800 against a maintained implementation whose README says consumers must compile against the plugin-shipped header and whose version contract is product version 1.0.0.

### Other source compatibility findings

- A scan of public asIScriptEngine, asIScriptContext, asIScriptGeneric, and asITypeInfo calls in the requested add-ons found maintained counterparts for all other engine-facing calls: generic argument/return access, user-data cleanup, GC, type lookup, context lifecycle, registration, and default-array APIs.
- The maintained header still exposes other APIs the reference sources use: asGetActiveContext, exclusive locks, asGetTypeTraits, RegisterDefaultArrayType, and type/engine user-data cleanup callbacks.
- Interface presence is not behavioural proof. The generic registration, save/load, execution, allocation-limit, and shutdown tests prescribed in tasks 1.17-1.25 remain required before support can be claimed.

### Allocation and execution-contract work

These are mandatory standalone adaptations, rather than optional cleanup:

- scriptarray defaults to global asAllocMem/asFreeMem, although CScriptArray::SetMemoryFunctions permits a host allocator. Route it to the counted standalone allocator.
- scriptdictionary uses asAllocMem/asFreeMem for some objects but allocates its cache with new/delete. Its map/unordered_map and string allocations are not host-accounted; its header explicitly notes that limitation. Use counted allocators/adapters for cache and all container/string storage.
- scriptstdstring owns a global CStdStringFactory and uses new/delete, string, regex, streams, and maps. Make it profile or engine scoped, prove shutdown cleanup, and route dynamic storage to the counting allocator. Its byte-oriented string implementation also requires an explicit UTF-8 policy.
- scriptmath has no material add-on heap ownership, but needs deterministic math/locale review. Its complex companion must not be registered.
- Array and dictionary operations can loop or execute user comparison functions. The adapted implementations need bounded cancellation checks compatible with the execution guard.

## 5. Minimum license-preserving task-1.4 import

Use this layout; the sibling directory names preserve the reference relative includes:

    Plugins/Angelscript/Standalone/ThirdParty/
      README.md
      AngelScriptAddons/
        scriptstdstring/
          scriptstdstring.h
          scriptstdstring.cpp
          scriptstdstring_utils.cpp
        scriptarray/
          scriptarray.h
          scriptarray.cpp
        scriptdictionary/
          scriptdictionary.h
          scriptdictionary.cpp
        scriptmath/
          scriptmath.h
          scriptmath.cpp

CMake should compile exactly those listed .cpp files, include the copied add-on root, and resolve angelscript.h from the maintained fork public include location. It must not compile scriptmathcomplex.cpp or copy an upstream AngelScript core source/header tree. Keeping the sibling paths matters because string utilities and dictionary directly include ../scriptarray/scriptarray.h.

Standalone/ThirdParty/README.md is the minimum additional licensing file called for by task 1.4. It must include:

1. The complete, unmodified local AngelScript zlib notice, including author/year and all three restrictions.
2. Source remote/URL, v2.38.0, full revision, exact copied paths, and preferably the source hashes above.
3. A clear statement that these are reviewed, altered sources rather than the original AngelScript distribution.
4. A file-by-file delta ledger. Initially it must list the two GetStringFactory to GetStringFactoryReturnTypeId replacements; later allocator, UTF-8, cancellation, and surface changes must be added.
5. A statement that Reference/angelscript-v2.38.0 is offline development reference only, never a build/runtime/package dependency.
6. The license relationship: plugin code is MIT under Plugins/Angelscript/LICENSE.md; copied add-on source retains AngelScript's zlib notice.

No reference README, upstream angelscript.h, full SDK, or scriptmathcomplex files are required for task 1.4. Altered files must be plainly marked and upstream notices/comments retained.

## 6. First native-runtime smoke: required and deferrable

The native runtime accepts only void main(const array<string> args) and int main(const array<string> args), per openspec/changes/feature-ue-angelscript-standalone-compiler/specs/angelscript-standalone-native-runtime/spec.md line 44.

| Priority | Components | Reason |
| --- | --- | --- |
| Required to register for the first real entry smoke | scriptarray and core scriptstdstring | The entry parameter is array<string>. Register the array template/default array type and string type by their generic entry points. The two API replacements are prerequisite. |
| Import in task 1.4, but defer registration from the first smoke | scriptstdstring_utils.cpp | split and join are not needed merely to construct and pass array<string> args. Register after string/array proof. |
| Import in task 1.4, but defer registration from the first smoke | scriptdictionary | The entry contract does not require dictionary. It depends on the proven string/array types and needs the larger allocator/GC/iteration audit. |
| Import in task 1.4, but defer registration from the first smoke | scriptmath | Native arithmetic does not require this convenience add-on. Register after base entry/execution proof. |
| Exclude | scriptmathcomplex | It is out of task scope and has no generic registration. |

Recommended initial generic registration order is RegisterScriptArray(engine, true), then RegisterStdString(engine), then construction of array<string> arguments. After that passes, add RegisterStdStringUtils(engine), RegisterScriptDictionary(engine), and RegisterScriptMath(engine) in separately tested slices. Task 1.4 still imports all four requested add-ons; this staging only limits the first smoke to declarations it objectively requires.

## Audit concern and next proof

This audit establishes availability, local provenance, license obligations, dependencies, generic dispatch, and one confirmed public API break. It does not establish that the current fork is already portable or that the add-ons meet the future allocation/cancellation contract.

After tasks 0.1 and 1.10 provide a no-UE AS_MAX_PORTABILITY CMake target, compile the nine listed source/header units against the maintained header and execute the staged generic-registration smoke before claiming integration support.

