// Theme: Feature.Inheritance. WorldStory BlueprintOverride out-param + Super writeback.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideOutParameterAndSuperMatrix
// Oracle: ComputeOutValue(20,"abc") return 51 out 27; DispatchOutValue(15,"abcd") return 43 out 23;
// BaseCallCount==2, ChildCallCount==2.
// Extra: empty handle null; Input 0 / empty Label Super path. FixtureIsolated.
// Keep BaseCallCount/ChildCallCount/LastOutValue.

UCLASS()
class ACoverageUFunctionOutOverrideBase : AActor
{
	UPROPERTY()
	int BaseCallCount = 0;

	UPROPERTY()
	int ChildCallCount = 0;

	UPROPERTY()
	int LastOutValue = 0;

	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|OutOverride", meta=(AdvancedDisplay="Label", DisplayName="Compute Out Value"))
	int ComputeOutValue(int Input, FString Label, int&out OutValue)
	{
		BaseCallCount += 1;
		OutValue = Input + Label.Len();
		LastOutValue = OutValue;
		return OutValue + 1;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|OutOverride")
	int DispatchOutValue(int Input, FString Label, int&out OutValue)
	{
		return ComputeOutValue(Input, Label, OutValue);
	}
}

UCLASS()
class ACoverageUFunctionOutOverrideChild : ACoverageUFunctionOutOverrideBase
{
	UFUNCTION(BlueprintOverride)
	int ComputeOutValue(int Input, FString Label, int&out OutValue)
	{
		ChildCallCount += 1;

		int ParentOut = 0;
		int ParentReturn = Super::ComputeOutValue(Input, Label, ParentOut);
		OutValue = ParentOut + 4;
		LastOutValue = OutValue;
		return ParentReturn + OutValue;
	}
}

bool Observe_OutOverride_EmptyHandleIsNull()
{
	ACoverageUFunctionOutOverrideChild Actor;
	return Actor == nullptr;
}

int Observe_OutOverride_DirectReturn(ACoverageUFunctionOutOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0128 setup: required ACoverageUFunctionOutOverrideChild is null");
	}
	int OutValue = 0;
	return Actor.ComputeOutValue(20, "abc", OutValue);
}

int Observe_OutOverride_DirectOut(ACoverageUFunctionOutOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0128 setup: required ACoverageUFunctionOutOverrideChild is null");
	}
	int OutValue = 0;
	Actor.ComputeOutValue(20, "abc", OutValue);
	return OutValue;
}

int Observe_OutOverride_DispatchReturn(ACoverageUFunctionOutOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0128 setup: required ACoverageUFunctionOutOverrideChild is null");
	}
	int OutValue = 0;
	return Actor.DispatchOutValue(15, "abcd", OutValue);
}

int Observe_OutOverride_DispatchOut(ACoverageUFunctionOutOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0128 setup: required ACoverageUFunctionOutOverrideChild is null");
	}
	int OutValue = 0;
	Actor.DispatchOutValue(15, "abcd", OutValue);
	return OutValue;
}

int Observe_OutOverride_ZeroInputEmptyLabelOut(ACoverageUFunctionOutOverrideChild Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0128 setup: required ACoverageUFunctionOutOverrideChild is null");
	}
	int OutValue = 0;
	Actor.ComputeOutValue(0, "", OutValue);
	return OutValue;
}
