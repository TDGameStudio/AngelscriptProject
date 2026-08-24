// Theme: World.Actor. C++ compiles this actor then VerifyByPath DestroyCalled
// and InvalidAfterDestroy. CSV marks NegativeDiagnostic; the method is a
// lifecycle oracle, not a compile-fail.
// C++: AngelscriptCoverageHandleTests.cpp::HandleDestroyActorInvalidatesReference
// Extra: missing Victim spawn is recorded as InvalidAfterDestroy without
// treating setup failure as success (BeginPlay still sets flags from IsValid).
// Spawn is the oracle (Victim = SpawnActor). FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageHandleDestroyActor : AActor
{
	UPROPERTY()
	AActor Victim;

	UPROPERTY()
	bool DestroyCalled = false;

	UPROPERTY()
	bool InvalidAfterDestroy = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Victim = SpawnActor(AActor::StaticClass());
		if (Victim != nullptr)
		{
			Victim.DestroyActor();
			DestroyCalled = true;
		}
		InvalidAfterDestroy = !IsValid(Victim);
	}
}
