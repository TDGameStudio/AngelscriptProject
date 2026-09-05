# Stable type identity verification

## TDD sequence

- Task `1.1` expected RED build `c1ac5ba74f66479f96da1a2cf5d6b3e8` failed because the planned canonical encoder header did not exist. Build `2e9727be28004c6493e95ae41ad4784c` then isolated missing digest value-type exports. After the local ABI repair, GREEN build `d5e23de0299741de9d510532644777c0` and exact Fast run `4d3a8defe17648f4bddd10b1349249cf` passed 6/6 declaration-identity tests.
- Task `1.2` expected RED build `e436284f00ed478b88d70ce260a9e577` failed on the deliberately absent structural TypeUse and compatibility-domain contracts. GREEN build `6003cc0dec2c42489c3532a65a180089` and exact Fast run `6ba7c1ce1dcb481780a916aee8d8f6b0` passed 13/13 cumulative identity tests.
- Task `2.1` expected RED build `9a5b2dd29a2648f4820b8bdb643018a2` failed on the absent scoped slot, requirement registry, runtime-generation ID, and one-way projection contracts. GREEN build `3222d8ed8967468ca305bf363a26de16` and exact Fast run `9620a764725a48ef81b437a958634ab0` passed 19/19 cumulative identity tests with zero warnings, errors, or skips.
- Final incremental Editor build `f66cff615ca240eea357fcaff5421b61` succeeded. Final exact Fast run `4e9a824a928c48598d9d0ee92efeeac8` passed 19/19 with 0 failed, 0 skipped, 0 not-run, 0 warnings, and 0 errors.

The final Automation report is `Saved/Harness/Unreal/Runs/4e9a824a928c48598d9d0ee92efeeac8/AutomationReport/index.json`. It enumerates only the three `NewVersion/NativeEngine/Identity` CQTest fixtures. No fixture creates or mutates an `asCScriptEngine`.

## Final content identity

| File | SHA-256 |
|---|---|
| `frontend/as_canonical_encoding.h` | `3f6670b21548ec380c78176d51076a6b71e35fbdcae3e1061f08f6e6b63cc9f3` |
| `frontend/as_canonical_encoding.cpp` | `18efd51d0f271ca35c6deaac8cc2916358737393f58fd4a8975fe14681e3c2b4` |
| `frontend/as_type_identity.h` | `806ca35a215e460eeb4c0c2c90fd1e7281b39d0181d1303a3985b9e388fb8a8f` |
| `frontend/as_type_identity.cpp` | `880ff39eb6c3d55b7e4f765f42f32e00b2f922cc29bfb8bfca94c1e9dd94fbed` |
| `Core/Artifacts/AngelscriptArtifactIdentity.h` | `7955993f599246fe46a2be323b0f95b3e5e755e2645246a5936790d2c3c19efd` |
| `Core/Artifacts/AngelscriptArtifactIdentity.cpp` | `b49cd66d9fc2f10693ff0fdf281643189b0cea2d3f8315a2891cad7f23d7d511` |
| `as_runtime_type_binding.h` | `eef3189c6bb1e425ad5f0d597fbcd7dd37326c6d6ea4776ec8a163db05cf13a0` |
| `as_runtime_type_binding.cpp` | `4fad09c32fe3270e67a0028b41a5135e5da54b4f36dc067ae828b216356b993c` |
| `AngelscriptNativeTypeDeclIdentityTests.cpp` | `e24b1c002d3c9e5ffac4a96440034070b9a8ea0193c22653a2f31247f37abac0` |
| `AngelscriptNativeTypeUseIdentityTests.cpp` | `0e385505e007898e7840c7d535fed60f78a3c1802d27582718334c6429201911` |
| `AngelscriptNativeTypeScopeIdentityTests.cpp` | `dfd85f14f1117158eb5fbfb6be1879d9f442059a0310d1e795137a56edb513dd` |
| current `stable-identity/spec.md` | `336341f76bfa60ff559ab4bbd2a57cd185f1c4c3c5913f48f64eb4413e9daab4` |

## Durable contract and knowledge

- Portable OpenSpec created parent domain `angelscript/language/types` and capability `angelscript/language/types/stable-identity`; all six verified requirements are synchronized without delta-operation headings.
- `stable-identity/knowledges/stable-type-identity-witnesses.md` retains the exact-witness, domain-separation, and scoped-projection guidance.
- Strict active-Change validation passed 1/1; strict all-current-spec validation passed 11/11.
- OpenSpec doctor run `e7a93981c4bf4a0c82d08ff2b107abde` reported valid with zero diagnostics; TaskPlan run `30112dfd2b1040aca151831d46fb9ef1` reported complete 6/6.

## Impact boundary

The Change establishes canonical identity values and one-way checked adapters. It does not create a live Engine, publish Builder candidates, change VM opcodes, change a cache/sidecar wire format, or add a Standalone consumer. The 137-action Task 2.1 build followed from owned public-header dependencies; it did not demonstrate a need to expand the test area.

Harness aggregate `Quick`, `Performance`, and `Integration` profiles, full UE suites, Standalone, Builder publication, VM, and legacy tests were intentionally omitted. The incremental Editor target and complete 19-test isolated Identity prefix directly prove the changed boundary.

