// Theme: Feature.Delegates. WorldStory Unbind removes only HandlerA.
// C++: AngelscriptDelegateTests.cpp::UnbindRemovesSpecificSubscriber
// sha256 from theme-refs TS-FEAT-0206; lines 564-604.
// Oracle: RunUnbindTest returns 1 (A stays 1, B becomes 2). Extra: defaults 0;
// second local independent. FixtureIsolated.

event void FOnPulse();

UCLASS()
class ATestDelegateUnbind : AActor
{
	UPROPERTY()
	FOnPulse OnPulse;

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
	int RunUnbindTest()
	{
		OnPulse.AddUFunction(this, n"HandlerA");
		OnPulse.AddUFunction(this, n"HandlerB");

		OnPulse.Broadcast();
		if (CountA != 1 || CountB != 1)
		{
			return 10;
		}

		OnPulse.Unbind(this, n"HandlerA");
		OnPulse.Broadcast();
		if (CountA != 1)
		{
			return 20;
		}
		if (CountB != 2)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_Unbind_Nominal(ATestDelegateUnbind Actor)
{
	if (Actor is null)
	{
		throw("Test_UnbindRemovesSpecificSubscriber setup: required Actor is null");
	}
	return Actor.RunUnbindTest();
}

int Observe_Unbind_DefaultEmpty(ATestDelegateUnbind Actor)
{
	if (Actor is null)
	{
		throw("Test_UnbindRemovesSpecificSubscriber setup: required Actor is null");
	}
	return Actor.CountA + Actor.CountB;
}

bool Observe_Unbind_CopyIndependence(ATestDelegateUnbind First, ATestDelegateUnbind Second)
{
	if (First is null)
	{
		throw("Test_UnbindRemovesSpecificSubscriber setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_UnbindRemovesSpecificSubscriber setup: required Second is null");
	}
	int FirstResult = First.RunUnbindTest();
	return FirstResult == 1 && First.CountA == 1 && First.CountB == 2 && Second.CountA == 0 && Second.CountB == 0;
}
