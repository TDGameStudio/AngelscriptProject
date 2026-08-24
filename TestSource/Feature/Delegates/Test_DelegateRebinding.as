// Theme: Feature.Delegates. WorldStory BindUFunction replaces the previous handler.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateRebinding
// Oracle after BeginPlay: Result==2. Extra: empty actor is null; pre-BeginPlay Result==0.
// FixtureIsolated.

delegate void FCoverageRebindingDelegate();

UCLASS()
class ACoverageDelegateRebindingActor : AActor
{
	UPROPERTY()
	int Result = 0;

	FCoverageRebindingDelegate OnDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDelegate.BindUFunction(this, n"Handler1");
		OnDelegate.Execute();

		OnDelegate.BindUFunction(this, n"Handler2");
		OnDelegate.Execute();
	}

	UFUNCTION()
	void Handler1()
	{
		Result = 1;
	}

	UFUNCTION()
	void Handler2()
	{
		Result = 2;
	}
}

bool Observe_Rebinding_EmptyDefaultIsNull()
{
	ACoverageDelegateRebindingActor Actor;
	return Actor == nullptr;
}

int Observe_Rebinding_ResultDefault(ACoverageDelegateRebindingActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0024 setup: required ACoverageDelegateRebindingActor is null");
	}
	return Actor.Result;
}
