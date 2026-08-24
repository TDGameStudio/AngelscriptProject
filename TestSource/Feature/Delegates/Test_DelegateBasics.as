// Theme: Feature.Delegates. WorldStory IsBound / BindUFunction / Execute / Clear.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateBasics
// Oracle after BeginPlay: Counter==3, DelegateWasCalled==true.
// Extra: empty actor is null; pre-BeginPlay Counter==0 / DelegateWasCalled==false.
// FixtureIsolated.

delegate void FCoverageSimpleDelegate();

UCLASS()
class ACoverageDelegateBasicsActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	bool DelegateWasCalled = false;

	FCoverageSimpleDelegate OnSimpleDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (!OnSimpleDelegate.IsBound())
		{
			Counter = 1;
		}

		OnSimpleDelegate.BindUFunction(this, n"HandleSimpleDelegate");

		if (OnSimpleDelegate.IsBound())
		{
			Counter = 2;
		}

		OnSimpleDelegate.Execute();

		OnSimpleDelegate.Clear();
		if (!OnSimpleDelegate.IsBound())
		{
			Counter = 3;
		}
	}

	UFUNCTION()
	void HandleSimpleDelegate()
	{
		DelegateWasCalled = true;
	}
}

bool Observe_DelegateBasics_EmptyDefaultIsNull()
{
	ACoverageDelegateBasicsActor Actor;
	return Actor == nullptr;
}

int Observe_DelegateBasics_CounterDefault(ACoverageDelegateBasicsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0017 setup: required ACoverageDelegateBasicsActor is null");
	}
	return Actor.Counter;
}

bool Observe_DelegateBasics_CalledDefaultFalse(ACoverageDelegateBasicsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0017 setup: required ACoverageDelegateBasicsActor is null");
	}
	return Actor.DelegateWasCalled;
}
