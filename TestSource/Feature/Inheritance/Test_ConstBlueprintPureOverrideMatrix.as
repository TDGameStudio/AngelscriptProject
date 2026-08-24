// Theme: Feature.Inheritance. WorldStory const BlueprintPure override dispatch.
// C++: AngelscriptCoverageUFunctionTests.cpp::ConstBlueprintPureOverrideMatrix
// Oracle: ComputePureValue(4,4)==42; DispatchPureValue(5,-3)==42. StoredValue default 7.
// Extra: empty handle null; default Bias path; zero Scale. FixtureIsolated. Keep StoredValue.

UCLASS()
class ACoverageUFunctionPureOverrideBase : AActor
{
	UPROPERTY()
	int StoredValue = 7;

	UFUNCTION(BlueprintPure, BlueprintEvent, Category="Coverage|PureOverride", meta=(DisplayName="Compute Pure Value", CompactNodeTitle="PURE", AdvancedDisplay="Bias"))
	int ComputePureValue(int Scale, int Bias = 1) const
	{
		return StoredValue * Scale + Bias;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|PureOverride")
	int DispatchPureValue(int Scale, int Bias = 1) const
	{
		return ComputePureValue(Scale, Bias);
	}
}

UCLASS()
class ACoverageUFunctionPureOverrideChild : ACoverageUFunctionPureOverrideBase
{
	UFUNCTION(BlueprintOverride)
	int ComputePureValue(int Scale, int Bias = 1) const
	{
		return StoredValue * Scale + Bias + 10;
	}
}

bool Observe_PureOverride_EmptyHandleIsNull()
{
	ACoverageUFunctionPureOverrideChild Actor;
	return Actor == nullptr;
}

int Observe_PureOverride_Direct(ACoverageUFunctionPureOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0129 setup: required ACoverageUFunctionPureOverrideChild is null");
	}
	return Actor.ComputePureValue(4, 4);
}

int Observe_PureOverride_Dispatch(ACoverageUFunctionPureOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0129 setup: required ACoverageUFunctionPureOverrideChild is null");
	}
	return Actor.DispatchPureValue(5, -3);
}

int Observe_PureOverride_DefaultBias(ACoverageUFunctionPureOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0129 setup: required ACoverageUFunctionPureOverrideChild is null");
	}
	return Actor.ComputePureValue(4);
}

int Observe_PureOverride_ZeroScaleBoundary(ACoverageUFunctionPureOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0129 setup: required ACoverageUFunctionPureOverrideChild is null");
	}
	return Actor.ComputePureValue(0, 0);
}
