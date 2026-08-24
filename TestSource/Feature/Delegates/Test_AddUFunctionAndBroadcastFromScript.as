// Theme: Feature.Delegates. WorldStory AddUFunction + Broadcast accumulation.
// C++: AngelscriptDelegateTests.cpp::AddUFunctionAndBroadcastFromScript
// sha256 from theme-refs TS-FEAT-0204; lines 435-472.
// Oracle: RunMulticastTest returns 1 (50 then 75). Extra: TotalReceived default 0;
// second local stays 0 after first run. FixtureIsolated.

event void FOnScoreChanged(int32 Score);

UCLASS()
class ATestDelegateMulticastScript : AActor
{
	UPROPERTY()
	FOnScoreChanged OnScoreChanged;

	UPROPERTY()
	int TotalReceived = 0;

	UFUNCTION()
	void HandleScore(int32 Score)
	{
		TotalReceived += Score;
	}

	UFUNCTION()
	int RunMulticastTest()
	{
		OnScoreChanged.AddUFunction(this, n"HandleScore");

		if (!OnScoreChanged.IsBound())
		{
			return 10;
		}

		OnScoreChanged.Broadcast(50);
		if (TotalReceived != 50)
		{
			return 20;
		}

		OnScoreChanged.Broadcast(25);
		if (TotalReceived != 75)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_MulticastScript_Nominal(ATestDelegateMulticastScript Actor)
{
	if (Actor is null)
	{
		throw("Test_AddUFunctionAndBroadcastFromScript setup: required Actor is null");
	}
	return Actor.RunMulticastTest();
}

int Observe_MulticastScript_DefaultEmpty(ATestDelegateMulticastScript Actor)
{
	if (Actor is null)
	{
		throw("Test_AddUFunctionAndBroadcastFromScript setup: required Actor is null");
	}
	return Actor.TotalReceived;
}

bool Observe_MulticastScript_CopyIndependence(ATestDelegateMulticastScript First, ATestDelegateMulticastScript Second)
{
	if (First is null)
	{
		throw("Test_AddUFunctionAndBroadcastFromScript setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_AddUFunctionAndBroadcastFromScript setup: required Second is null");
	}
	int FirstResult = First.RunMulticastTest();
	return FirstResult == 1 && First.TotalReceived == 75 && Second.TotalReceived == 0;
}
