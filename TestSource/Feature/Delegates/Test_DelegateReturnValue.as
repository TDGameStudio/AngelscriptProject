// Theme: Feature.Delegates. WorldStory bool return and int return+param delegates.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateReturnValue
// Oracle after BeginPlay: BoolResult==true, IntResult==100 (50*2).
// Extra: empty actor is null; pre-BeginPlay false / 0. FixtureIsolated.

delegate bool FCoverageBoolRetDelegate();
delegate int FCoverageIntRetIntDelegate(int Value);

UCLASS()
class ACoverageDelegateRetValActor : AActor
{
	UPROPERTY()
	bool BoolResult = false;

	UPROPERTY()
	int IntResult = 0;

	FCoverageBoolRetDelegate OnBoolRetDelegate;
	FCoverageIntRetIntDelegate OnIntRetIntDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnBoolRetDelegate.BindUFunction(this, n"HandleBoolRetDelegate");
		BoolResult = OnBoolRetDelegate.Execute();

		OnIntRetIntDelegate.BindUFunction(this, n"HandleIntRetIntDelegate");
		IntResult = OnIntRetIntDelegate.Execute(50);
	}

	UFUNCTION()
	bool HandleBoolRetDelegate()
	{
		return true;
	}

	UFUNCTION()
	int HandleIntRetIntDelegate(int Value)
	{
		return Value * 2;
	}
}

bool Observe_DelegateRetVal_EmptyDefaultIsNull()
{
	ACoverageDelegateRetValActor Actor;
	return Actor == nullptr;
}

bool Observe_DelegateRetVal_BoolDefaultFalse(ACoverageDelegateRetValActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0019 setup: required ACoverageDelegateRetValActor is null");
	}
	return Actor.BoolResult;
}

int Observe_DelegateRetVal_IntDefault(ACoverageDelegateRetValActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0019 setup: required ACoverageDelegateRetValActor is null");
	}
	return Actor.IntResult;
}
