# Source Storage and Host Compatibility Evidence

Local source inspection on 2026-09-13; no product tests executed. Runtime-relative paths below start at Plugins/Angelscript/Source/AngelscriptRuntime/.

## Common Source and host fields

Core/AngelscriptSource.h:55 defines VirtualPath, ModuleName, RelativeFilename, AbsoluteFilename, SourceText, SourceKind, and bHasSourceText. Core/AngelscriptSourceProvider.h:51 uses this record for enumeration, loading, and state queries. Cache/AngelscriptCacheSourceDiscovery.cpp:637-690 reads host fields including ModuleName, RelativeFilename, and SourceKind. Removing them would not be an SDK-only change.

The accepted design keeps the record and fields, changes SourceText to FUtf8String, and submits prepared shared-const references. SDK rejection of unprepared input does not read AbsoluteFilename. Host mount parsing must not constrain the generic SDK logical path.

## Actual body copying

angelscript/frontend/Basic/as_source_snapshot.cpp:60-82 implements AddFile by appending supplied bytes to a TArray after identity checks. This duplicates the submitted body. SourceManager queries and the character stream use pointer/length slices with bounds checks; neither requires another complete body.

AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h converts through FTCHARToUTF8, appends into an array, and then calls Snapshot.AddFile. This is an observed fixture materialization chain, not proof about every production caller.

## UTF-8 storage and views

The inspected UE 5.8 Containers/Utf8String.h uses UTF8CHAR string storage. UnrealString.h.inl supplies move construction, ConstructFromPtrSize, pointer access, and Len excluding the trailing terminator. String.cpp.inl converts into the final destination allocation.

```cpp
const FUtf8String& Text = Source.GetSourceText();
TConstArrayView<uint8> Bytes(
    reinterpret_cast<const uint8*>(*Text), Text.Len());
```

This view neither transcodes nor allocates nor copies the body. It cannot outlive its Source owner. Explicit length preserves embedded NUL for diagnosis; coordinates remain UTF-8 byte offsets.

## Boundaries

FString-to-UTF-8 conversion necessarily creates different encoded storage. Shared constness does not constrain other mutable aliases. Tokens, ASTs, and genuinely new literal values may allocate. These observations do not certify dormant LSP builds or end-to-end legacy-host zero-copy behavior.
