# Phase 02 final-engine offline contract

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


Status: passed.

The final external-consumer, Release-package, regression, and path-scope
reconciliation is recorded in `v1-closeout-20260801.md`; that record is the
current authority for final counts and hashes.

## Producer

The producer observes the final `asIScriptEngine`, supplements it with
read-only Unreal/reflection/module/plugin facts, exports host-surface and
active script-baseline declarations, exports adapters and reviewed Asset
Registry facts, then atomically publishes:

```text
manifest.json
symbols.jsonl
assets.jsonl
```

The records contain no native/live address, C++ or script source/body,
bytecode/executable code, asset payload, or mutable editor state. Symbol and
asset scope completeness are independent; symbol scope is mandatory.

Final focused evidence:

- Runtime OfflineContract: `12/12`,
  `Saved/Tests/standalone-resource-parameter-contract/20260731_090835_456_82e8afdb`.
- Editor OfflineContract: `9/9`,
  `Saved/Tests/standalone-final-offline-editor-v7/20260731_092506_134_8f04e529`.
- UE Development build: succeeded,
  `Saved/Build/standalone-resource-parameter-contract/20260731_090809_936_e3ca1f61`.

## Current deterministic UE 5.8 packaged-default export

The official release command was run twice against the checked-in
`AngelscriptProject.uproject` under
`UE 5.8.0-55116800+++UE5+Release-5.8`, with
`-BundleKind=DefaultEngine -AssetRoots=/Game`. The two ignored outputs are:

- `Saved/AngelscriptStandalone/UE5.8/default-engine-a`
- `Saved/AngelscriptStandalone/UE5.8/default-engine-b`

Both contain 130,068 symbols and 9 assets with complete symbol and asset
scope. The manifest identifies producer project `AngelscriptProject`, includes
the exact 711 loaded modules and 282 loaded plugins (including
`Angelscript`, `AngelscriptGameplayTags`, and `AngelscriptGAS`), and contains
no machine-absolute path. All three files are byte-identical:

| File | SHA-256 |
| --- | --- |
| `manifest.json` | `a8dfe32e63967a6ef49cd6c3e8089e24be0393dab3f8d003d9ec2d25eb434ffa` |
| `symbols.jsonl` | `911698ba49bf65c6ac7abacd5938691ce0872e81bbfd16c17a5d0a7ff3d71f54` |
| `assets.jsonl` | `28a4028fc2418ca96f5a82734265ca9dfdf59f5903056882039b77be98d45d9f` |

Bundle identity:
`f40af33a32752146226f0ed92eaaed7c6e35de4c14caa27c969527237c80ae1c`.

The commandlet class itself returned `0` and published valid atomic bundles.
The two commandlet logs are:

- `Saved/Commandlet/standalone-default-ue58-export-a/20260731_191108_644_0596a28f/Commandlet.log`;
- `Saved/Commandlet/standalone-default-ue58-export-b/20260731_191246_681_c31c09f1/Commandlet.log`.

The outer local UE processes returned `1` because this host logged unrelated
project/editor startup errors (missing GameFeatureData AssetManager rule and
ModelContextProtocol port 8000 already bound). Each log explicitly records
the `AngelscriptOfflineExport` commandlet result as `0` after atomic
publication. Those host errors are retained as environmental evidence rather
than being suppressed.

The reopened producer policy tests were developed red/green:

- red minimal-host expectation replacement:
  `Saved/Tests/standalone-default-ue58-red/20260731_190440_137_ec588a34`;
- green complete `DefaultEngine` producer scope and project identity:
  `Saved/Tests/standalone-default-ue58-core-final/20260731_192427_201_b61841d0`,
  `12/12`.
- final Editor commandlet/export contract after packaged-role terminology
  cleanup:
  `Saved/Tests/standalone-default-ue58-editor-final-renamed/20260731_192333_683_2ae00b0d`,
  `9/9`.

The exact source archive installed by CMake is
`Standalone/Contracts/UE5.8/default-engine.zip`, 20,377,909 bytes, SHA-256
`1af0373bba10bcf50ce12a36ea7b7238570f7414a9b04a8404d0dd74d4813dd8`.
CMake expands it to the ordinary three-file contract and rejects any
per-file hash mismatch; the runtime consumer has no archive-loading path.

## 2026-08-01 external consuming-project closeout

The parent-owned smoke runner created a transient content-only Unreal project
under `Saved` with no C++ host module, used the plugin-owned commandlet through
the standard `RunCommandlet.ps1 -ProjectFile` entry point, and exported the
Project bundle twice: once to the project-local default and once to an explicit
destination supplied through a JSON argument file. Both exports were
byte-identical.

The exported bundle contains 126,319 symbols, zero assets, complete Project
replacement semantics, and identity
`4cca84f065cc09cc08d8ca4f9ef37b4f82ae4b8186eb9088505e64d4ea9322ab`.
The CLI extracted from the final Release ZIP consumed the explicit bundle with
profile `ue-validation`, bundle kind `project`, result `complete`, and the same
identity. Machine-readable evidence is
`Saved/StandaloneExternalSmoke/20260801_183731_228_ddb2b2d7/Summary.json`.

Script-baseline replacement now intentionally distinguishes LanguageCore's
internal short module identity from the offline-contract identity. The latter
is the SHA-256 of
`module-id-v1\n<logical-module-name>\n/Angelscript/Game/<logical-path>` for
project scripts. Replacement remains stable-ID based and fails closed when a
same-name baseline has a different contract identity.
