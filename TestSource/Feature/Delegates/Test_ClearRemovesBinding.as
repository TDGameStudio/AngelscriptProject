// Theme: Feature.Delegates. WorldStory BindUFunction, Execute, then Clear.
// C++: AngelscriptDelegateTests.cpp::ClearRemovesBinding
// sha256 from theme-refs TS-FEAT-0200; lines 165-201.
// Oracle: RunClearTest returns 1 (bound, Execute once, then unbound).
// Extra: CallCount default 0; second local CallCount stays 0 after first RunClearTest.
// FixtureIsolated. Clear owns unbind.

delegate void FSimpleNotify();

UCLASS()
class ATestDelegateClear : AActor
{
	UPROPERTY()
	FSimpleNotify OnNotify;

	UPROPERTY()
	int CallCount = 0;

	UFUNCTION()
	void HandleNotify()
	{
		CallCount += 1;
	}

	UFUNCTION()
	int RunClearTest()
	{
		OnNotify.BindUFunction(this, n"HandleNotify");
		if (!OnNotify.IsBound())
		{
			return 10;
		}

		OnNotify.Execute();
		if (CallCount != 1)
		{
			return 20;
		}

		OnNotify.Clear();
		if (OnNotify.IsBound())
		{
			return 30;
		}

		return 1;
	}
}

int Observe_ClearRemovesBinding_Nominal(ATestDelegateClear Actor)
{
	if (Actor is null)
	{
		throw("Test_ClearRemovesBinding setup: required Actor is null");
	}
	return Actor.RunClearTest();
}

int Observe_ClearRemovesBinding_DefaultCallCount(ATestDelegateClear Actor)
{
	if (Actor is null)
	{
		throw("Test_ClearRemovesBinding setup: required Actor is null");
	}
	return Actor.CallCount;
}

bool Observe_ClearRemovesBinding_CopyIndependence(ATestDelegateClear First, ATestDelegateClear Second)
{
	if (First is null)
	{
		throw("Test_ClearRemovesBinding setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ClearRemovesBinding setup: required Second is null");
	}
	int FirstResult = First.RunClearTest();
	return FirstResult == 1 && First.CallCount == 1 && Second.CallCount == 0 && !Second.OnNotify.IsBound();
}
