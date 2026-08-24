// Theme: Feature.Delegates. WorldStory two multicast subscribers both fire.
// C++: AngelscriptDelegateTests.cpp::MultipleSubscribers
// sha256 from theme-refs TS-FEAT-0205; lines 497-539.
// Oracle: RunMultiSubTest returns 1 (counts 1 then 2). Extra: CountA/CountB default 0;
// second local stays 0. FixtureIsolated.

event void FOnTick();

UCLASS()
class ATestDelegateMultiSub : AActor
{
	UPROPERTY()
	FOnTick OnTick;

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
	int RunMultiSubTest()
	{
		OnTick.AddUFunction(this, n"HandlerA");
		OnTick.AddUFunction(this, n"HandlerB");

		OnTick.Broadcast();

		if (CountA != 1)
		{
			return 10;
		}
		if (CountB != 1)
		{
			return 20;
		}

		OnTick.Broadcast();
		if (CountA != 2)
		{
			return 30;
		}
		if (CountB != 2)
		{
			return 40;
		}

		return 1;
	}
}

int Observe_MultiSub_Nominal(ATestDelegateMultiSub Actor)
{
	if (Actor is null)
	{
		throw("Test_MultipleSubscribers setup: required Actor is null");
	}
	return Actor.RunMultiSubTest();
}

int Observe_MultiSub_DefaultEmpty(ATestDelegateMultiSub Actor)
{
	if (Actor is null)
	{
		throw("Test_MultipleSubscribers setup: required Actor is null");
	}
	return Actor.CountA + Actor.CountB;
}

bool Observe_MultiSub_CopyIndependence(ATestDelegateMultiSub First, ATestDelegateMultiSub Second)
{
	if (First is null)
	{
		throw("Test_MultipleSubscribers setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_MultipleSubscribers setup: required Second is null");
	}
	int FirstResult = First.RunMultiSubTest();
	return FirstResult == 1 && First.CountA == 2 && First.CountB == 2 && Second.CountA == 0 && Second.CountB == 0;
}
