# Task 7.5 Assets Verification

## Outcome

Task 7.5 records and installs the asset-bundle, asset-registry, asset-manager, generated-override and data-table providers in a fresh Engine. Six tests use only transient packages, objects, an in-memory dynamic row struct and non-mutating registry queries. The selected family contains exactly 74 installed member contributions and 32 native recipes.

Formatter-only TypeInfrastructure contributions remain owned by task 7.10, which explicitly applies ToString and finalization providers after every family surface is complete.

## Setup and pre-existing behavior

- Build `ca7d04c165c54d5bbf85ff0706fb848c` exposed one fixture compile error before execution; corrected without changing product behavior. Build `6c0eb3076b624f97917dbc6e902c8570` succeeded.
- Run `ef00eaf664c148cc9a2d7a7f05acc354` discovered all six cases and asserted when a task-7.10 formatter contribution accessed the legacy target Engine. The executable task-7.5 provider selection was narrowed to its six type/member/override providers.
- Run `e5f6c16ff2a4492fa9bbfe0fbbb1f18c` then produced one Engine-free accounting control and five frozen-image failures: reflected signatures required `TSet<FTopLevelAssetPath>`, while the reflected `FTopLevelAssetPath` declaration had no native hash recipe. This was a setup failure before behavioral execution, not behavioral RED.
- A rejected attempt to redeclare the reflected struct as a native ValueClass produced the deterministic incompatible-definition diagnostic in run `2efcc8feb1aa432c84e0e2598685d66d`. The final implementation instead enriches the existing reflected declaration with its typed native definition.
- The remaining bindings already behaved correctly once the complete image could be created. They are recorded as characterization/regression coverage; no retroactive behavioral RED is claimed. Runs `7ca1612001324711b66f4fdce1b73406` and `efef353681644a599fd690d33617801c` exposed and removed two fixture-only direct-context/dynamic-table hazards.

## Implementation

- AssetRegistry and FPrimaryAssetId namespaces now use detached recording scopes.
- The generated AssetManager mixin override remains active for direct Engine registration and skips the detached recorder, where loaded reflection owns generated/reflective dispatch.
- `AssetRegistry.Manual` uses `ExistingClassForTarget<FTopLevelAssetPath>`, preserving the reflected identity while supplying native construction, destruction, equality and hash recipes. The installed `GetHash()` member exposes the same native hash contract.
- The data-table fixture inserts an owned row directly into its transient row map and removes/destroys it with scoped cleanup, avoiding global assets and editor change broadcasts from a synthetic no-export struct.

## Exact GREEN

Command:

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Runtime.Assets.'; Fast = $true; TimeoutMs = 600000 }
```

Harness run `cb09b7e447ee4de88e7c09e4602a18f9` passed 6/6 with zero warnings and zero errors:

- `BundleCopiesNameAndAssetPath`
- `ManagerAndRegistrySurfacesExecuteWithoutDiskAssets`
- `MissingTableRowRetainsOutputAndReturnsFalseSurface`
- `ProvidersAreCompleteAndTransientObjectsRelease`
- `TopLevelAndSoftPathsRoundTrip`
- `TransientTableRowRoundTripsKnownFields`

The verified source SHA-256 is `7b012e3078e2f65c4791cf0eb92858db37dd0a30e3b1a50ebfeeccf5651e49e3`; `UnrealEditor-AngelscriptTest.dll` SHA-256 is `897a2530f325b37d128b414ad5d0f16782c3513b27a767b66a41da7e15eea87e`.

## Shared regression proof

Harness run `92e5e13ce8c14a26a9db1808ddc0d70b` selected `Angelscript.UnitTest.RuntimeBindings.` and passed 278/278 with zero warnings, errors, skips or incomplete tests. This covers every affected recording, reflected-definition, template hash, frozen-image and native-call contract. No disk assets were created or published. No broader suite was selected because the demonstrated impact remains inside RuntimeBindings.
