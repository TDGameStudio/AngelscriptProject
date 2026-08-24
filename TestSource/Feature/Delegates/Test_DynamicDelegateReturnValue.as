// Theme: Feature.Delegates. WorldStory: single-cast dynamic delegates return values.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateReturnValue
// Spawn + BeginPlay oracle: BoolResult==true, IntResult==100 (Execute(50) doubles).
// Extra: defaults false/0; unbound Execute is not invoked here. Keep BoolResult, IntResult.
// FixtureIsolated.

delegate bool FCoverageDynamicBoolRetEvent();
delegate int FCoverageDynamicIntRetIntEvent(int Value);

UCLASS()
class ACoverageDynamicRetValActor : AActor
{
	UPROPERTY()
	bool BoolResult = false;

	UPROPERTY()
	int IntResult = 0;

	FCoverageDynamicBoolRetEvent OnBoolRetEvent;
	FCoverageDynamicIntRetIntEvent OnIntRetIntEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Return value only
		OnBoolRetEvent.BindUFunction(this, n"HandleBoolRetEvent");
		BoolResult = OnBoolRetEvent.Execute();

		// Return value + parameter
		OnIntRetIntEvent.BindUFunction(this, n"HandleIntRetIntEvent");
		IntResult = OnIntRetIntEvent.Execute(50);
	}

	UFUNCTION()
	bool HandleBoolRetEvent()
	{
		return true;
	}

	UFUNCTION()
	int HandleIntRetIntEvent(int Value)
	{
		return Value * 2;
	}
}

bool Observe_BoolResult_DefaultFalse(ACoverageDynamicRetValActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateReturnValue setup: required Actor is null");
	}
	return !Actor.BoolResult;
}

int Observe_IntResult_DefaultZero(ACoverageDynamicRetValActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateReturnValue setup: required Actor is null");
	}
	return Actor.IntResult;
}

int Observe_IntReturn_ZeroBoundary()
{
	return 0 * 2;
}
