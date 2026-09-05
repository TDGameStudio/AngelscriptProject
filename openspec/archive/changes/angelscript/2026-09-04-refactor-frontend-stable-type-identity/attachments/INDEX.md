# INDEX

## Current position

Tasks `1.1`, `1.2`, and `2.1` are GREEN: nominal declaration witnesses, recursive structural type uses, qualifier-role validation, schema/ABI domain isolation, artifact-local slots, generation-local runtime IDs, and checked legacy projections pass 19 focused tests. Continue with the final incremental build and exact Identity acceptance prefix.

Task `1.1` evidence: expected RED build `c1ac5ba74f66479f96da1a2cf5d6b3e8` failed only because the planned canonical encoder header was absent. Build `2e9727be28004c6493e95ae41ad4784c` exposed two missing digest value-type exports at link time; the local ABI declaration was repaired. GREEN build `d5e23de0299741de9d510532644777c0` and exact Identity run `4d3a8defe17648f4bddd10b1349249cf` passed 6/6 with zero warnings, errors, or skips.

Task `1.2` evidence: expected RED build `e436284f00ed478b88d70ce260a9e577` failed on the deliberately absent structural TypeUse and compatibility-domain contracts. GREEN build `6003cc0dec2c42489c3532a65a180089` and exact Identity run `6ba7c1ce1dcb481780a916aee8d8f6b0` passed 13/13 with zero warnings, errors, or skips.

Task `2.1` evidence: expected RED build `9a5b2dd29a2648f4820b8bdb643018a2` failed on the deliberately absent scoped slot, requirement registry, runtime-generation ID, and one-way projection contracts. GREEN build `3222d8ed8967468ca305bf363a26de16` compiled the public artifact/runtime adapter surface in 137 actions; the wider incremental action set was caused by the owned public-header dependency and required no test-scope expansion. Exact Identity run `9620a764725a48ef81b437a958634ab0` passed 19/19 in 21.8 seconds with zero warnings, errors, or skips. The fixture creates no `asCScriptEngine`; collision buckets use exact requirement witnesses after digest indexing, and durable encoders reject artifact-local `TypeSlot` and generation-local `RuntimeTypeId` values.

Final focused acceptance: incremental Editor build `f66cff615ca240eea357fcaff5421b61` succeeded, then exact Fast run `4e9a824a928c48598d9d0ee92efeeac8` passed 19/19 in 19.2 seconds with zero warnings, errors, or skips. The report is `Saved/Harness/Unreal/Runs/4e9a824a928c48598d9d0ee92efeeac8/AutomationReport/index.json`. No aggregate Harness profile, full UE suite, Standalone, Builder publication, or VM test was run because the verified impact remains the identity authority and its checked projections.

Durable synchronization: portable OpenSpec created the previously absent `angelscript/language/types` domain and `angelscript/language/types/stable-identity` capability, then the verified requirements and reusable witness knowledge were promoted. Strict validation passed for this Change (`1/1`) and all current specs (`11/11`). The parent-domain creation was a local CLI structural prerequisite omitted from the Task Card, not a Harness failure and not a semantic replan.

## Hard conclusions

- `TypeDeclKey`, `TypeUseKey`, schema, ABI, artifact-local `TypeSlot`, and generation-local `RuntimeTypeId` are distinct identity domains.
- Canonical witness equality is authoritative; BLAKE3-256 is an index and fast rejection value.
- Runtime `typeId`, pointers, offsets, and callable handles are current-generation projections only.
- UE core types are allowed inside ThirdParty, but their indexes, addresses, layout, and iteration order never enter canonical identity.

## Forbidden

- Do not parse stable-key strings as the semantic type graph or bind by digest/short name alone.
- Do not include absolute paths, source lines, traversal order, runtime IDs, pointer values, or `FName` indices in stable keys.
- Do not expand this Change into sidecar/cache/bytecode versioning or an engine-free VM rewrite.
- Do not perform live Engine lookup, candidate validation, relocation, or transactional publication in this Change.

## Attachment index

- `talks/talk-20260905-010301-stable-type-identity-boundary.md` — settled identity-layer model and rejected runtime/Clang numeric-ID interpretations — read before changing key composition or adapter ownership.
- `knowledges/stable-type-identity-witnesses.md` — candidate reusable evidence for exact witnesses, structural type uses, and generation-local projection — read when adding persisted or runtime consumers.
- `data/identity-verification.md` — focused RED/GREEN sequence, final managed build and 19-test evidence, content hashes, durable synchronization, and explicit impact exclusions.
- `data/completed-closure.yaml` — explicit completed disposition for the deterministic OpenSpec archive operation.
- `data/workflow-evaluation.md` — canonical completed-closure workflow evaluation written last against the final active Change digest.
