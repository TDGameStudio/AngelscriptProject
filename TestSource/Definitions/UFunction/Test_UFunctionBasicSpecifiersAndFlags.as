// Theme: Definitions.UFunction. WorldStory NotBlueprintCallable / Callable / Pure / CallInEditor+Exec.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UFunctionBasicSpecifiersAndFlags
// Oracle: functions generate; Value default 7; CallableAdd(3)==10; PureValue==7; EditorExecMethod +=10.
// Extra: CallableAdd(0) empty addend; nullptr actor is the empty handle.
// FixtureIsolated. Keep Value name.

UCLASS()
class ACoverageMetaUFunctionFlagsActor : AActor
{
	UPROPERTY()
	int Value = 7;

	UFUNCTION(NotBlueprintCallable)
	void BasicMethod()
	{
		Value += 1;
	}

	UFUNCTION(BlueprintCallable, Category = "Coverage|Functions")
	int CallableAdd(int Input)
	{
		return Value + Input;
	}

	UFUNCTION(BlueprintPure)
	int PureValue() const
	{
		return Value;
	}

	UFUNCTION(CallInEditor, Exec)
	void EditorExecMethod()
	{
		Value += 10;
	}
}

bool Observe_Flags_NominalDefault(ACoverageMetaUFunctionFlagsActor Actor)
{
	return Actor.PureValue() == 7 && Actor.CallableAdd(3) == 10 && Actor.Value == 7;
}

bool Observe_Flags_ZeroAddendEmpty(ACoverageMetaUFunctionFlagsActor Actor)
{
	return Actor.CallableAdd(0) == Actor.Value && Actor.PureValue() == Actor.Value;
}

bool Observe_Flags_NullDefault()
{
	ACoverageMetaUFunctionFlagsActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Flags_IncrementBoundary(ACoverageMetaUFunctionFlagsActor Actor)
{
	int Before = Actor.Value;
	Actor.BasicMethod();
	Actor.EditorExecMethod();
	return Actor.Value == Before + 11 && Actor.PureValue() == Before + 11;
}
