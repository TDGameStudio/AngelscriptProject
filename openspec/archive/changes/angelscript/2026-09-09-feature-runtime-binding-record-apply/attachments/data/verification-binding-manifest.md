# Intended binding manifest verification

Task 1.6 adds an engine-free inspection projection and an explicit staged export-to-directory API. A sealed Store produces one deterministic JSON document plus `types.csv`, `classes.csv`, `members.csv`, `globals.csv`, `providers.csv`, `reflection.csv`, `exclusions.csv`, and `summary.csv`. Collection inspection enumerates the compiled descriptors without evaluating conditions or callbacks. Store inspection labels scope and stage, includes recording and validation status, and allows a sealed semantic failure to be exported with `valid=false`.

The projection separates intended AngelScript declarations from captured reflection identities and exclusions. It preserves qualified owner/member identities, accepted declarations and defaults, primary typed-reference category, base/interfaces/aliases/templates, native layout, property shape, access/modifier facts, copied constants, provider/source/policy, symbolic target/lifetime categories, ordered native and lifecycle recipes, and reflection enum values as decimal strings. No native address is serialized or dereferenced. Directory publication writes a private staging directory and renames it only after all files succeed; existing or otherwise unavailable destinations fail with an empty result.

## Behavioral RED

Harness run `befe3ce879534d6eaea01ad44d48bce2` selected `Angelscript.UnitTest.RuntimeBindings.Recording.Manifest.` against the initial compilable implementation. It ran eight cases: five controls succeeded and three semantic assertions failed. The failures exposed missing typed-reference output, readiness of the deliberately incomplete intended fixture, and the constant mutation assertion. Subsequent fixture-only diagnosis runs distinguished invalid object-handle layout from exporter behavior.

## Final GREEN

- Build Harness run `8de04ed6f7b54eedbed76bf6cda82bf5`: succeeded, exit code 0.
- Exact Automation Harness run `bcb23e856db84adca89115147ba52ced`: 10/10 succeeded, zero warnings and zero errors.
- Shared `Angelscript.UnitTest.RuntimeBindings.` Harness run `1d84e7a1d425444880ea164834f76cdb`: 125/125 succeeded, zero warnings and zero errors.

The exact cases cover qualified Pair/X/Sum, derived/base/interface identities, overloaded-shaped global declarations and constant 7; semantic order/address stability and constant mutation; nested reflected containers, exclusion and signed/int64 enum precision; callback-free literal and compiled Collection inspection; JSON/CSV Unicode/quote handling; sealed invalid diagnostic export; unsealed/occupied destination rejection; and repeated projection/export after a rejected sealed mutation. The retained schema examples are `sample-binding-manifest.json` and `sample-binding-members.csv`. Full Runtime scope remains an 8.2 publication claim; these samples are explicitly selected-family fixtures.

## Identities

| Path | SHA-256 |
|---|---|
| `Core/AngelscriptTypeBindInfoInspection.h` | `162DDF55B006902712F9A5E938A9CB8DE2B4E691992B3D40552D633B182112D2` |
| `Core/AngelscriptTypeBindInfoInspection.cpp` | `D137E482AA85CEC296EFE709843843101FDB5174F98A05EEA4B43A73CBBA0C86` |
| `Dump/AngelscriptBindingDump.h` | `28F251FC2A94005DDCF0E2491D003FD27D1ABE5539F90063687DC66DC43917E4` |
| `Dump/AngelscriptBindingDump.cpp` | `9622BDE659E42686A69B6206D611A6103EE135FFC044CEF2E06922B6B261E080` |
| `RuntimeBindingManifestTests.cpp` | `B27FD12C29F9696CC830D07370B56A4B4A5C8F77C1EC2F8FDE6DC706AB036CAB` |
| `UnrealEditor-AngelscriptRuntime.dll` | `17886EAE0059F1293147E51909907305BCA142492FAB38EEA7586AEA0463830C` |
| `UnrealEditor-AngelscriptTest.dll` | `102DCEEB26054E379A35CBE954B1B54B46217F74152F64D78D9C7AE8179573A5` |

The source and binary hashes were captured after the final build and before the final exact and shared runs.
