// Theme: Feature.Delegates. WorldStory dynamic single-cast IsBound / BindUFunction / Execute / Clear.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateBasics
// Oracle after BeginPlay: Counter==3, DelegateWasCalled==true.
// Extra: empty actor is null; pre-BeginPlay Counter==0 / DelegateWasCalled==false.
// FixtureIsolated.

delegate void FCoverageDynamicSimpleDelegate();

UCLASS()
class ACoverageDynamicDelegateBasicsActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	bool DelegateWasCalled = false;

	FCoverageDynamicSimpleDelegate OnDynamicEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (!OnDynamicEvent.IsBound())
		{
			Counter = 1;
		}

		OnDynamicEvent.BindUFunction(this, n"HandleDynamicDelegate");

		if (OnDynamicEvent.IsBound())
		{
			Counter = 2;
		}

		OnDynamicEvent.Execute();

		OnDynamicEvent.Clear();
		if (!OnDynamicEvent.IsBound())
		{
			Counter = 3;
		}
	}

	UFUNCTION()
	void HandleDynamicDelegate()
	{
		DelegateWasCalled = true;
	}
}

bool Observe_DynamicBasics_EmptyDefaultIsNull()
{
	ACoverageDynamicDelegateBasicsActor Actor;
	return Actor == nullptr;
}

int Observe_DynamicBasics_CounterDefault(ACoverageDynamicDelegateBasicsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0030 setup: required ACoverageDynamicDelegateBasicsActor is null");
	}
	return Actor.Counter;
}

bool Observe_DynamicBasics_CalledDefaultFalse(ACoverageDynamicDelegateBasicsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0030 setup: required ACoverageDynamicDelegateBasicsActor is null");
	}
	return Actor.DelegateWasCalled;
}
