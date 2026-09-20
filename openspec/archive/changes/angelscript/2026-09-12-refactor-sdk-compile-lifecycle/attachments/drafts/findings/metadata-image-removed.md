# asCMetadataImage is gone

User (verbatim): `asCMetadataImage 这个不要了哈`

Q8 had been “retire from public SDK, maybe keep as internal scratch”. That is reopened and replaced: **the type does not remain**, public or internal.

## What holds definitions instead

```text
asCBuilder                         // until Registration
 ├─ pending asCTypeInfo*
 ├─ pending asCScriptFunction*      // 稳定字节码挂在这里
 ├─ pending asCGlobalProperty*
 └─ asCCompileOutput               // 对外描述 + 诊断；不是定义图

asCEngineCompileRegistration
 └─ Engine 拥有同一批指针          // 之后跟 Engine 生命周期
```

No `metadataOwner` back to an Image. No `Engine.metadataImages`. No Building/Frozen/Attaching/Attached/Retired helper.

The missing cross-module ring is `asCModuleDefinitionSet` (Q21/N1), not Image and not pending arrays on Builder with no Take.

`asCDefinitionConsumer` today produces an Image; after the shrink it fills Builder-owned pending arrays (or equivalent). `Emit` takes Session + those pending functions, not `const asCMetadataImage*`.

## Binding

BindInfo Draft still creates Image in current source. Binding stays out of this draft’s implementation; failing bind tests may be commented. The SDK contract is still: do not keep the type.
