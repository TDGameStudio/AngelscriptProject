// Theme: Feature.Inheritance. WorldStory BlueprintOverride metadata + virtual dispatch.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideInheritanceMetadataMatrix
// Oracle: DecoratedCompute(20,"direct")==30; DispatchDecoratedCompute(32,"dispatch")==42;
// BaseCallCount==0, ChildCallCount==2, LastLabel=="dispatch:child".
// Extra: empty handle null; empty Label; parent body stays unused.
// FixtureIsolated. Keep BaseCallCount/ChildCallCount/LastLabel.

UCLASS()
class ACoverageUFunctionMetadataBase : AActor
{
	UPROPERTY()
	int BaseCallCount = 0;

	UPROPERTY()
	int ChildCallCount = 0;

	UPROPERTY()
	FString LastLabel;

	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|Override", meta=(DisplayName="Decorated Compute", Keywords="coverage override metadata", AdvancedDisplay="Label", ToolTip="Parent metadata copied to override"))
	int DecoratedCompute(int Value, FString Label)
	{
		BaseCallCount += 1;
		LastLabel = Label;
		return Value + 1;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Override")
	int DispatchDecoratedCompute(int Value, FString Label)
	{
		return DecoratedCompute(Value, Label);
	}
}

UCLASS()
class ACoverageUFunctionMetadataChild : ACoverageUFunctionMetadataBase
{
	UFUNCTION(BlueprintOverride)
	int DecoratedCompute(int Value, FString Label)
	{
		ChildCallCount += 1;
		LastLabel = Label + ":child";
		return Value + 10;
	}
}

bool Observe_MetadataOverride_EmptyHandleIsNull()
{
	ACoverageUFunctionMetadataChild Actor;
	return Actor == nullptr;
}

int Observe_MetadataOverride_DirectChild(ACoverageUFunctionMetadataChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0127 setup: required ACoverageUFunctionMetadataChild is null");
	}
	return Actor.DecoratedCompute(20, "direct");
}

int Observe_MetadataOverride_DispatchChild(ACoverageUFunctionMetadataChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0127 setup: required ACoverageUFunctionMetadataChild is null");
	}
	return Actor.DispatchDecoratedCompute(32, "dispatch");
}

bool Observe_MetadataOverride_DispatchState(ACoverageUFunctionMetadataChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0127 setup: required ACoverageUFunctionMetadataChild is null");
	}
	Actor.DecoratedCompute(20, "direct");
	Actor.DispatchDecoratedCompute(32, "dispatch");
	return Actor.BaseCallCount == 0
		&& Actor.ChildCallCount == 2
		&& Actor.LastLabel == "dispatch:child";
}

FString Observe_MetadataOverride_EmptyLabelBoundary(ACoverageUFunctionMetadataChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0127 setup: required ACoverageUFunctionMetadataChild is null");
	}
	Actor.DecoratedCompute(0, "");
	return Actor.LastLabel;
}
