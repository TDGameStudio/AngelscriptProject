# UTF-8 Source Storage and Views

Disposition: candidate. Origin: angelscript/refactor-builder-source-entry; local UE 5.8 and SDK inspection on 2026-09-13. No implementation verification or capability promotion yet.

## Reusable Insight

Owning encoding storage and a compiler byte view are complementary. FUtf8String can own the one UTF-8 body while TConstArrayView<uint8> represents only its address and explicit byte count. Creating the view does not copy or transcode the text.

## Evidence

[Storage evidence](../drafts/findings/builder-source-storage-evidence.md) records UE move/pointer/length support, direct conversion into final storage, and the existing character stream's bounded access.

## Boundaries

A view needs a retained owner and stable storage. Const shared references do not freeze other aliases. UTF-16/FString conversion is a real encoding allocation; moving an already prepared UTF-8 body is different. Use explicit length rather than strlen, and preserve original byte coordinates for invalid bytes, NUL, BOM, and CRLF.

## Application

Retain a shared Source version across compilation and escaped location consumers. Form internal views only when reading. Test pointer identity and owner lifetime, not merely byte equality; separately account for legitimate token/AST allocations and opt-in debug dumps.

## Sources

[Accepted source contract](../drafts/design.md#common-source-and-preparation), [storage evidence](../drafts/findings/builder-source-storage-evidence.md).
