// Theme: Definitions.UFunction. WorldStory: BP child preserves script UFUNCTION dispatch.
// C++: AngelscriptBlueprintChildTests.cpp::ScriptUFunctionCallable
// Compile parent, create BP child, InvokeIntScriptFunction RecordExternalCall(77).
// Oracle: ScriptCallCount == 1, LastCallValue == 77.
// Extra: defaults are 0; RecordExternalCall(0) is the zero-value boundary.
// FixtureIsolated. Keep ScriptCallCount / LastCallValue. Runner owns spawn.

UCLASS()
class ATestBPChildScriptUFunctionCallableParent : AActor
{
	UPROPERTY()
	int ScriptCallCount = 0;

	UPROPERTY()
	int LastCallValue = 0;

	UFUNCTION()
	void RecordExternalCall(int Value)
	{
		ScriptCallCount += 1;
		LastCallValue = Value;
	}
}

bool Observe_RecordExternalCall_Defaults(ATestBPChildScriptUFunctionCallableParent Actor)
{
	return Actor.ScriptCallCount == 0 && Actor.LastCallValue == 0;
}

bool Observe_RecordExternalCall_Nominal(ATestBPChildScriptUFunctionCallableParent Actor)
{
	Actor.RecordExternalCall(77);
	return Actor.ScriptCallCount == 1 && Actor.LastCallValue == 77;
}

bool Observe_RecordExternalCall_ZeroBoundary(ATestBPChildScriptUFunctionCallableParent Actor)
{
	Actor.RecordExternalCall(0);
	return Actor.ScriptCallCount == 1 && Actor.LastCallValue == 0;
}

bool Observe_RecordExternalCall_CopyIndependence(
	ATestBPChildScriptUFunctionCallableParent First,
	ATestBPChildScriptUFunctionCallableParent Second)
{
	First.RecordExternalCall(77);
	return First.ScriptCallCount == 1
		&& First.LastCallValue == 77
		&& Second.ScriptCallCount == 0
		&& Second.LastCallValue == 0;
}
