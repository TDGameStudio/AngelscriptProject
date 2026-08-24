// Theme: HotReload VersionPair Before. Warmup carrier so initial compile is finished.
// C++: AngelscriptHotReloadEnumDelegateTests.cpp::BroadcastEnumCreatedOnFirstCompile
// Retained: UEnumCreatedWarmupCarrier Revision=1 in the warmup module.
// Replaced: not this class; After.as is a different module that first-compiles the enum.
// Oracle: warmup compile marks initial compile finished; OnEnumCreated does not fire here.
// FixtureIsolated. Load Before then After in recorded order.

UCLASS()
class UEnumCreatedWarmupCarrier : UObject
{
	UPROPERTY()
	int Revision = 1;
}
