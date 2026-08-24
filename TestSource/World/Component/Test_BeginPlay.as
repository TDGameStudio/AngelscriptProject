// Theme: World.Component. WorldStory: TestCase component BeginPlay sets bReady.
// C++: AngelscriptComponentTests.cpp::BeginPlay
// CreateComponent TestCase + BeginPlayActor, then VerifyByPath bReady true. Keep bReady.
// sha256=68bc68a07d6954e3398be2e4444762b87f9006ad53ab430eb63c95b9787584e8; lines 118-131.
// Extra: local construct leaves bReady false; writing one instance leaves the other false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class UTestComponentBeginPlay : UActorComponent
{
	UPROPERTY()
	bool bReady = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bReady = true;
	}
}

bool Observe_ComponentBeginPlay_DefaultFalse(UTestComponentBeginPlay Comp)
{
	if (Comp is null)
	{
		throw("Test_BeginPlay setup: required Comp is null");
	}
	return Comp.bReady == false;
}

bool Observe_ComponentBeginPlay_CopyIndependence(UTestComponentBeginPlay First, UTestComponentBeginPlay Second)
{
	if (First is null)
	{
		throw("Test_BeginPlay setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BeginPlay setup: required Second is null");
	}
	First.bReady = true;
	return First.bReady && Second.bReady == false;
}
