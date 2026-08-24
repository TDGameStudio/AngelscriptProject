// Theme: HotReload VersionPair After. New Bonus/Epoch fields, bumped defaults.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastOldAndNewTypes
// Retained: FHotReloadDelegatePayload, UHotReloadDelegateCarrier, Value, Revision names.
// Replaced: Value=2, Bonus=7, Revision=2, Epoch=9. Struct/class objects replaced.
// Oracle: ClassReloadCount 1, StructReloadCount 1, PostReloadCount 1. FixtureIsolated.

USTRUCT()
struct FHotReloadDelegatePayload
{
	UPROPERTY()
	int Value = 2;

	UPROPERTY()
	int Bonus = 7;
}

UCLASS()
class UHotReloadDelegateCarrier : UObject
{
	UPROPERTY()
	int Revision = 2;

	UPROPERTY()
	int Epoch = 9;
}
