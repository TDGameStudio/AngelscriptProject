// Theme: Feature.Delegates. WorldStory ExecuteIfBound unbound / bound / cleared.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateExecuteIfBound
// Oracle after BeginPlay: Counter==3. Extra: empty actor is null; pre-BeginPlay Counter==0.
// FixtureIsolated.

delegate void FCoverageExecuteIfBoundDelegate();

UCLASS()
class ACoverageDelegateExecuteIfBoundActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	FCoverageExecuteIfBoundDelegate OnDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDelegate.ExecuteIfBound();
		Counter = 1;

		OnDelegate.BindUFunction(this, n"HandleDelegate");
		OnDelegate.ExecuteIfBound();

		OnDelegate.Clear();
		OnDelegate.ExecuteIfBound();
		Counter = 3;
	}

	UFUNCTION()
	void HandleDelegate()
	{
		Counter = 2;
	}
}

bool Observe_ExecuteIfBound_EmptyDefaultIsNull()
{
	ACoverageDelegateExecuteIfBoundActor Actor;
	return Actor == nullptr;
}

int Observe_ExecuteIfBound_CounterDefault(ACoverageDelegateExecuteIfBoundActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0020 setup: required ACoverageDelegateExecuteIfBoundActor is null");
	}
	return Actor.Counter;
}
