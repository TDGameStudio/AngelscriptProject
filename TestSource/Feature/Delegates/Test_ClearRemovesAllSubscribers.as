// Theme: Feature.Delegates. WorldStory multicast Clear drops every subscriber.
// C++: AngelscriptDelegateTests.cpp::ClearRemovesAllSubscribers
// sha256 from theme-refs TS-FEAT-0207; lines 629-663.
// Oracle: RunClearTest returns 1 (Count stays 1 after Clear+Broadcast). Extra: Count 0;
// second local independent. FixtureIsolated.

event void FOnPing();

UCLASS()
class ATestDelegateMCClear : AActor
{
	UPROPERTY()
	FOnPing OnPing;

	UPROPERTY()
	int Count = 0;

	UFUNCTION()
	void Handler()
	{
		Count += 1;
	}

	UFUNCTION()
	int RunClearTest()
	{
		OnPing.AddUFunction(this, n"Handler");
		OnPing.Broadcast();
		if (Count != 1)
		{
			return 10;
		}

		OnPing.Clear();
		if (OnPing.IsBound())
		{
			return 20;
		}

		OnPing.Broadcast();
		if (Count != 1)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_MCClear_Nominal(ATestDelegateMCClear Actor)
{
	if (Actor is null)
	{
		throw("Test_ClearRemovesAllSubscribers setup: required Actor is null");
	}
	return Actor.RunClearTest();
}

int Observe_MCClear_DefaultEmpty(ATestDelegateMCClear Actor)
{
	if (Actor is null)
	{
		throw("Test_ClearRemovesAllSubscribers setup: required Actor is null");
	}
	return Actor.Count;
}

bool Observe_MCClear_CopyIndependence(ATestDelegateMCClear First, ATestDelegateMCClear Second)
{
	if (First is null)
	{
		throw("Test_ClearRemovesAllSubscribers setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ClearRemovesAllSubscribers setup: required Second is null");
	}
	int FirstResult = First.RunClearTest();
	return FirstResult == 1 && First.Count == 1 && Second.Count == 0 && !Second.OnPing.IsBound();
}
