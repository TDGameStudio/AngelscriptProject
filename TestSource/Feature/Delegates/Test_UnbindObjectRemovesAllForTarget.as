// Theme: Feature.Delegates. WorldStory UnbindObject removes every handler on this.
// C++: AngelscriptDelegateTests.cpp::UnbindObjectRemovesAllForTarget
// sha256 from theme-refs TS-FEAT-0208; lines 688-729.
// Oracle: RunUnbindObjTest returns 1. Extra: counts default 0; second local independent.
// FixtureIsolated.

event void FOnSignal();

UCLASS()
class ATestDelegateUnbindObj : AActor
{
	UPROPERTY()
	FOnSignal OnSignal;

	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	UFUNCTION()
	void HandlerA()
	{
		CountA += 1;
	}

	UFUNCTION()
	void HandlerB()
	{
		CountB += 1;
	}

	UFUNCTION()
	int RunUnbindObjTest()
	{
		OnSignal.AddUFunction(this, n"HandlerA");
		OnSignal.AddUFunction(this, n"HandlerB");

		OnSignal.Broadcast();
		if (CountA != 1 || CountB != 1)
		{
			return 10;
		}

		OnSignal.UnbindObject(this);
		if (OnSignal.IsBound())
		{
			return 20;
		}

		OnSignal.Broadcast();
		if (CountA != 1 || CountB != 1)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_UnbindObj_Nominal(ATestDelegateUnbindObj Actor)
{
	if (Actor is null)
	{
		throw("Test_UnbindObjectRemovesAllForTarget setup: required Actor is null");
	}
	return Actor.RunUnbindObjTest();
}

int Observe_UnbindObj_DefaultEmpty(ATestDelegateUnbindObj Actor)
{
	if (Actor is null)
	{
		throw("Test_UnbindObjectRemovesAllForTarget setup: required Actor is null");
	}
	return Actor.CountA + Actor.CountB;
}

bool Observe_UnbindObj_CopyIndependence(ATestDelegateUnbindObj First, ATestDelegateUnbindObj Second)
{
	if (First is null)
	{
		throw("Test_UnbindObjectRemovesAllForTarget setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_UnbindObjectRemovesAllForTarget setup: required Second is null");
	}
	int FirstResult = First.RunUnbindObjTest();
	return FirstResult == 1 && First.CountA == 1 && First.CountB == 1 && Second.CountA == 0 && Second.CountB == 0;
}
