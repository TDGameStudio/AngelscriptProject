# Task 4.7 FString and FName verification

## Scope and boundary

Task 4.7 records and installs the fixed `FString` and `FName` provider surfaces, including array-dependent parsing and joining, defaults, namespace functions, native formatting overloads, mutable indexing and existing callable suffixes. The nine wildcard `?` entries whose behavior depends on the Engine-local `ToString` contribution list remain assigned to task 7.10 by the accepted task boundary.

The selected providers are `FString.ExplicitBindings` and `FName.Functions`, composed with the complete installable declaration catalog. The exact fixed inventory is:

| Owner/source | Recorded members |
|---|---:|
| `FString`, from `FString.ExplicitBindings` | 65 |
| namespace `FString`, from `FString.ExplicitBindings` | 18 |
| all contributions from `FName.Functions` | 17 |
| Total fixed task-4.7 contributions | 100 |

## RED

The initial exact run `2716fcb2fe6042cf95ce1a462e0a6f93` aborted while recording the first case because `BindFStringConversion` queried `GetTargetToStringList()` without a target Engine. This established the Engine-local contribution-list boundary but did not qualify as the grouped RED report.

After the provider could enter recording without an Engine, exact run `6275b187ade94d58bac0b1a3085771ee` produced the required complete grouped RED:

- outcome `Failed`, process exit `255`;
- 6 total, 0 succeeded, 6 failed;
- 0 warnings, 6 errors;
- summary SHA-256 `e12eb5abf956cbde98240799eb9d772137da39a1cc34e1163346fdc894206b9c`.

All cases stopped at the missing detached callable grammar for the real provider declaration `FString& Append(const FString& Other) accept_temporary_this`. The source diagnostic was `unexpected tokens after callable declaration (bytes 38..59)`. This invalidated the task file boundary and produced applied replan `replan-20260908-170752-string-declaration-suffixes` before the parser was changed.

## Implementation

- `BindFStringConversion` now records its fixed surface through the detached `FAngelscriptBinds` namespace path without reading an Engine-local `ToString` list.
- FString and FName infrastructure retain their detached native definitions but defer live `asITypeInfo`, string-factory and `ToString` registry mutation until an Engine-backed pass.
- The declaration parser accepts the existing `accept_temporary_this` and `no_discard` callable suffixes after the identity-bearing signature. Unknown or repeated trailing tokens remain rejected.
- Wildcard `?` format/conversion functions are omitted only during detached task-4.7 recording and remain present in the legacy Engine-backed callback pending their task-7.10 detached recipes.

## Exact GREEN

Final build run `f96143331b1b4ed6a31a726410534c78` succeeded with exit 0. Exact test run `5f4493795be548c5b06a1ab40be27b24` passed all six cases with zero warnings and zero errors; its summary SHA-256 is `3a6472336f1b40ce3552b2569d8337ec05062fa67886c833048547544eb522dd`.

Complete case paths:

1. `Angelscript.UnitTest.RuntimeBindings.Values.StringName.StringName.CompleteFStringAndFNameProviderSurfacesAreRecorded`
2. `Angelscript.UnitTest.RuntimeBindings.Values.StringName.StringName.CopyThenAppendProducesAbcdWithoutChangingOriginal`
3. `Angelscript.UnitTest.RuntimeBindings.Values.StringName.StringName.FNameEqualityAndStringRoundTrip`
4. `Angelscript.UnitTest.RuntimeBindings.Values.StringName.StringName.InvalidStringIndexRaisesTheRuntimeIndexContract`
5. `Angelscript.UnitTest.RuntimeBindings.Values.StringName.StringName.JoinAAndBWithDash`
6. `Angelscript.UnitTest.RuntimeBindings.Values.StringName.StringName.ParseIntoArraySplitsACommaB`

The installed native calls proved copying/appending, array-backed parsing and joining, FName equality/string round-trip, the current invalid-index exception contract, and the exact 65/18/17 provider inventory.

## Adjacent verification

- Shared `Angelscript.UnitTest.RuntimeBindings.` run `4f38d4a6ccda4bec812c43afb24d445a`: 173/173 succeeded, zero warnings/errors, exit 0, summary SHA-256 `47e9a6d9238fd88832484ad83838ce6d28a43c120634a0f23d22776115a8f2be`.
- Adjacent `Angelscript.UnitTest.NativeEngine.MetadataImage.` run `1b15ae51e85b4297b233b74376f29ef4`: 23/23 succeeded, zero warnings/errors, exit 0, summary SHA-256 `b0653657bc16c9525b9f3d944dc735fe206eba9de89146b0e2a87a2b01f051ea`.

No broader build, legacy suite, Quick, Integration or Performance run was selected: the change affects detached binding declaration parsing and the fixed string/name provider callbacks, both covered by the exact, full shared RuntimeBindings, and adjacent metadata-image selectors.

## Final source and binary identity

| Path | SHA-256 | Bytes |
|---|---|---:|
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp` | `4e757aa955dc9c80d55937d5d68278e5274c30835ac467e8dc46a2da61b83fc9` | 88226 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp` | `6222a37051e8db0a121c90d6199027d504290d4d3889de45ede7bdfa4892125a` | 14328 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.cpp` | `fbca4191085f2448ddb43df496bbda5fd3667e1c045209576f4968d9cc6c0493` | 12977 |
| `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingStringNameTests.cpp` | `883f9de9f9a708f2a80a9faff2f6feb583b07413e2930787bcaa0c3003029bc0` | 8535 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` | `1f792227d651cde34f727f5790d02570fecf94c6f51a0093650da45902b709e3` | 16536576 |
| `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` | `2d6f44135cc9e4282ba4ad893f9482d835809255eb6578cba58971db46808bfa` | 8778240 |

The source and binary hashes were captured after the final build and remained unchanged through the exact and adjacent test runs.

