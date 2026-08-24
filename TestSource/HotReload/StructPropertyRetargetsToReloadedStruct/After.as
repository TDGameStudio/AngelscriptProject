// Theme: HotReload VersionPair After. Owner Payload retargets to reloaded struct.
// C++: AngelscriptHotReloadStructTests.cpp::StructPropertyRetargetsToReloadedStruct ReloadV2Source
// Retained: FHotReloadStructPropertyPayload; UHotReloadStructPropertyOwner; ConfigureAndRead; RunOwner names.
// Replaced: struct/class objects; Bonus field; ConfigureAndRead writes Value=20 Bonus=22.
// Oracle After: RunOwner == 42; old Payload property still bound to old struct.
// FixtureIsolated. Load Before then After in recorded order.

USTRUCT()
struct FHotReloadStructPropertyPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

UCLASS()
class UHotReloadStructPropertyOwner : UObject
{
	UPROPERTY()
	FHotReloadStructPropertyPayload Payload;

	UFUNCTION()
	int ConfigureAndRead()
	{
		Payload.Value = 20;
		Payload.Bonus = 22;
		return Payload.Value + Payload.Bonus;
	}
}

int RunOwner(UHotReloadStructPropertyOwner Owner)
{
	return Owner.ConfigureAndRead();
}
