// Theme: HotReload VersionPair Before. Owner Payload retargets to reloaded struct.
// C++: AngelscriptHotReloadStructTests.cpp::StructPropertyRetargetsToReloadedStruct ReloadV1Source
// Retained on old objects: Payload struct without Bonus; old owner property still points at old struct.
// Replaced in After: struct and owner UClass identity; Bonus field; ConfigureAndRead 12 -> 20+22.
// Oracle Before: RunOwner == 12.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructPropertyPayload
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class UHotReloadStructPropertyOwner : UObject
{
	UPROPERTY()
	FHotReloadStructPropertyPayload Payload;

	UFUNCTION()
	int ConfigureAndRead()
	{
		Payload.Value = 12;
		return Payload.Value;
	}
}

int RunOwner(UHotReloadStructPropertyOwner Owner)
{
	return Owner.ConfigureAndRead();
}
