# Shared Artifact Identity Golden Vectors

## Status And Ownership

These vectors freeze identity schema version `1` as implemented by
`FAngelscriptArtifactCanonicalWriter` and
`FAngelscriptArtifactIdentityBuilder`. They are the cross-change contract for
Cache V2 and the sibling `refactor-as-static-jit-external-module` provider.

The authoritative implementation and executable fixtures are:

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.h`;
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/Artifacts/AngelscriptArtifactIdentity.cpp`;
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptArtifactIdentityTests.cpp`.

StaticJIT consumes only the public value types, schema/domain encoding, and
these vectors. It does not consume Cache V2 records, packs, manifests,
generation selection, source authority, disk paths, or reload policy.

Changing any canonical byte, domain, field order, field width, enum value, or
normalization rule is an identity-schema change. Such a change requires a new
schema version, regenerated vectors, synchronized Cache and StaticJIT tests,
and an explicit compatibility decision; silently updating the expected hashes
is forbidden.

## Canonical Writer Contract

Every identity stream starts with:

```text
UTF-8 bytes "UEAS-ARTIFACT"
NUL byte
uint32 little-endian identity schema version (1)
uint32 little-endian domain byte length
domain UTF-8 bytes
```

All integers use fixed-width little-endian encoding. Booleans use one byte,
`0` or `1`. Hash fields write all 32 raw bytes. Byte arrays and UTF-8 strings
use a `uint32` little-endian byte length followed by exactly those bytes.

The primitive fixture writes domain `module`, then `uint8 0x7f`,
`uint16 0x1234`, `uint32 0x78563412`, `uint64 0x0102030405060708`,
`true`, `false`, raw hash bytes `00..1f`, byte array `aa bb`, and UTF-8
string `Aé`. Its exact canonical bytes are:

```text
554541532d41525449464143540001000000060000006d6f64756c65
7f34121234567808070605040302010100
000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f
02000000aabb0300000041c3a9
```

Its BLAKE3-256 result is:

```text
92d4b174180cfda1e596ed3b40717ed97e2e62cec65a95f07ab12b2ac490850d
```

The stable type-entity discriminator is extended without renumbering existing
values: `Class=1`, `Struct=2`, `Interface=3`, `Enum=4`, `Delegate=5`,
`Typedef=6`, and `Funcdef=7`. Typedef and funcdef are TypeKey entities; a
delegate/funcdef signature remains a separately owned
`DelegateSignature=37` FunctionKey. Existing vectors below are byte-identical;
Task 2B-1 adds executable enum and declaration-key coverage before records are
frozen.

## Frozen Domain Vectors

| Domain/result | Canonical fixture inputs | Expected BLAKE3-256 |
|---|---|---|
| `module` / `FAngelscriptStableModuleKey` | mount `Game`; validated logical path `Gameplay/Hero.as`; module `Gameplay.Hero` | `b6318b710ea6fa80cab1300a994f94f7528177ed6340c8c5fd388bb9a4608901` |
| `type` / `FAngelscriptStableTypeKey` | module key above; namespace `Gameplay`; kind `Class`; declaration `class AHero : AActor`; sorted traits `Blueprintable`, `Transient=false` | `9f40c2dae35bde5e33cee3cb5643bdd4d9eff0f5ad8d9d494746c8bab0f2cbac` |
| `function` / ordinary `FAngelscriptStableFunctionKey` | owner kind `Type`; owner key above; namespace `Gameplay`; kind `Method`; declaration `int Compute(int Value) const`; sorted traits `const`, `final=false` | `acc715df1e889d80cd194751b559ba819f3c71d178907aee3ff7473817dc666b` |
| `function` / synthetic module initializer | owner kind `Module`; module key above; namespace `Gameplay`; kind `ModuleInitializer`; declaration `void $module_init()`; sorted traits `startup`, `synthetic` | `95c046ac732d0ec0339a22f001836ed105962195aac3991b37c0fa39c425ec85` |
| `global` / `FAngelscriptStableGlobalKey` | module key above; namespace `Gameplay`; kind `GlobalVariable`; name `Difficulty`; type `const int`; sorted traits `config`, `readonly` | `21ab3180e18fee31c37451969b8c8a36e548c31b1ac85efa3ebe9a704be20065` |
| `property` / `FAngelscriptStablePropertyKey` | owner type key above; kind `Property`; name `Health`; type `float`; sorted traits `EditAnywhere`, `Replicated` | `ca384a931e9e740a5ec5c31971aacb51e2400ce2b015cae214db6b452fe19f4e` |
| `function-source` / `FAngelscriptFunctionSourceDigest` | kind `Method`; source `return Value + 1;`; sorted options `optimize=true`, `preprocessor=v1` | `f5f0713214fdc38f629425c0bdecfcc4e6e57a25030ad314aa3031e6898c46cd` |
| `function-input` / `FAngelscriptFunctionInputDigest` | source digest above; canonically sorted fingerprints derived from `dependency:Gameplay::SharedType=v3` and `dependency:Gameplay::SharedGlobal=v5` through the `compatibility` domain | `79f055c2756c00ed6684b3964938c0af12e38d7b032a53674c2112163a9f2f4b` |
| `function-execution` / execution content | byte payload `01 02 03` | `aa8ac2c22a3a1a67937bcaaa9aa2e641d65d759cbd181ad4283b8e6edb779246` |
| `function-debug` / debug content | byte payload `10 20` | `c4afa75e722008d03691b8bb4f8f1759fdd02cd1032142cf01b00e2f89ff4d2d` |
| `compatibility` / `FAngelscriptCacheCompatibilityKey` | sorted inputs `bytecode-abi=7`, `cache-schema=2`, `platform=Win64` | `c33a5dbefd943e446a91cb9e4f923a2d75ecf615c3f3f8c88ad89d9f8aaa33af` |
| `context` / `FAngelscriptCacheContextKey` | sorted inputs `configuration=Development`, `debug=true`, `target=Editor` | `38aadabf648ee783d14a3bc32d76b786f2647ea2adccb62b3581ff9463768e6a` |
| `profile` / `FAngelscriptArtifactProfileKey` | compatibility key and Editor context key above, each as full 32-byte values | `85c25f64159a3ff0d393e11c8bf2f42579494faa0e8c8a7ab3250e0c5ce1f26b` |

The executable fixtures build independent insertion-order variants for type,
ordinary function, synthetic function, global, property, source options,
dependency collection, compatibility inputs, and context inputs. Each variant
must resolve to the same frozen full hash after its required canonical sort.

## Logical Path Boundary

`FAngelscriptLogicalVirtualPath` has neither a public raw-string constructor
nor a default constructor. `TryCreateLogicalVirtualPath` and
`TryBuildModuleKey` return an unset result for empty paths, drive-qualified
host paths, slash-rooted paths, UNC paths, and `..` traversal that escapes the
logical root. They normalize separators, duplicate separators, `.` segments,
and resolvable relative `..` segments while preserving logical case.

Consequently, moving a project between host directories or drives cannot
change a stable module key because no absolute host coordinate can be passed
to `BuildModuleKey`. Case-insensitive collision detection belongs to the later
SourceIndex boundary and remains generation-fatal there.

## Authoritative Width And Forbidden Coordinates

All persistence, equality, ordering, collision checks, Cache selection, and
StaticJIT matching use all 256 bits. `ToDisplayGuid()` is diagnostic only and
uses the first 128 bits. The executable collision fixture proves that equal
display GUIDs with different trailing hash bytes remain distinct.

Identity descriptors intentionally exclude numeric AngelScript FunctionId,
process/native pointers or addresses, line/column, `FName` indices, random
values, allocation ordinals, and registration order. Compile-time descriptor
shape assertions and the domain goldens jointly guard that contract.
