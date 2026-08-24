// Theme: HotReload VersionPair Before. Payload Value=1, carrier Revision=1.
// C++: AngelscriptHotReloadDelegateTests.cpp::BroadcastOldAndNewTypes
// Retained after reload: FHotReloadDelegatePayload, UHotReloadDelegateCarrier, Value, Revision.
// Replaced in After: Payload Bonus=7; carrier Epoch=9; Value/Revision defaults 2.
// Oracle: ClassReloadCount 1, StructReloadCount 1. FixtureIsolated.

USTRUCT()
struct FHotReloadDelegatePayload
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class UHotReloadDelegateCarrier : UObject
{
	UPROPERTY()
	int Revision = 1;
}
