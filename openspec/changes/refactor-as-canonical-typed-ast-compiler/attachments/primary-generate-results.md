# Section 8 Primary Generate gate notes

Canonical remains non-default.

## 8.1–8.2 Native-form catalog

`Angelscript.TestModule.StaticJIT.NativeFormCatalog` **6/6**
(`D:\as-cta\Saved\Tests\canonical-ast-native-form-catalog\20260821_045454_532_55b0dbaf`)

Process-global `FAngelscriptNativeFormCatalog` is keyed by stable declaration + target profile. Real bind attachment publishes HeaderInline / ModuleExported / Bridge recipes. Engine teardown does not invalidate catalog lookup.

## 8.3–8.8 Matching / contained Generate

`Angelscript.TestModule.StaticJIT.PrimaryCanonicalASTGenerate` **9/9**
(`D:\as-cta\Saved\Tests\canonical-ast-primary-generate-8-4c\20260821_052329_359_bdb6fff1`)

Covered:

- matching profile leases retained AST, no `StaticJITGeneration` Engine
- discard → `ASTSnapshotRequired`; unfinished compile → `AuthoritativeEngineStale`
- Hot Reload application freeze while leases are held; queued file changes survive
- catalog lookup without a sibling Engine
- owned-output-only writes; sentinel files outside the inventory remain
- early-fail stages write no owned files and do not create generation Engines
- sequential EditorDevelopment + GameShipping: at most one extra Engine live
- matching AST dump leases the primary snapshot and does not emit Provider files

Typed `ProjectSourceGraph` compiles retain canonical AST (`ASTRetentionPolicy=1`); bytecode capture may discard.

## 8.9 prefixes

| Gate | Result |
| --- | --- |
| `Tools\RunBuild.ps1 -Label canonical-ast-primary-generate-8-4b -NoXGE` | exit 0 |
| `Angelscript.TestModule.StaticJIT` | **431/431** (`20260821_052500_259_41786148`) |
| `Angelscript.TestModule.HotReload` | **127/127** (`20260821_053840_736_b2784a55`) |
| `Angelscript.TestModule.Cache` | **555/555** (`20260821_054053_513_8dfd7e4a`) |

`superseded-change-map.md` is unchanged: native-form catalog, matching Generate, contained sequential generation, and dump absorption still match the recorded mapping.
