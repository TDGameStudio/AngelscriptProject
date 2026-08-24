// Theme: World.Component. WorldStory: TestCase component EndPlay sets bCleanedUp.
// C++: AngelscriptComponentTests.cpp::ReceiveEndPlay
// BeginPlay + Destroy host + TickWorld, then VerifyByPath bCleanedUp true. Keep bCleanedUp.
// sha256=6210078ff15fed236b3298aa18cfebd0602a2bc5c94335e1bd75f53be98cb93d; lines 217-230.
// Extra: local construct leaves bCleanedUp false; writing one instance leaves the other false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class UTestComponentReceiveEndPlay : UActorComponent
{
	UPROPERTY()
	bool bCleanedUp = false;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		bCleanedUp = true;
	}
}

bool Observe_ReceiveEndPlay_DefaultFalse(UTestComponentReceiveEndPlay Comp)
{
	if (Comp is null)
	{
		throw("Test_ReceiveEndPlay setup: required Comp is null");
	}
	return Comp.bCleanedUp == false;
}

bool Observe_ReceiveEndPlay_CopyIndependence(UTestComponentReceiveEndPlay First, UTestComponentReceiveEndPlay Second)
{
	if (First is null)
	{
		throw("Test_ReceiveEndPlay setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ReceiveEndPlay setup: required Second is null");
	}
	First.bCleanedUp = true;
	return First.bCleanedUp && Second.bCleanedUp == false;
}
