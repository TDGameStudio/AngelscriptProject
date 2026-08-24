// Theme: Feature.Inheritance. WorldStory BeginPlay dispatches another script UFUNCTION.
// C++: AngelscriptActorScriptOverrideTests.cpp::BeginPlayCallsAnotherScriptUFunction
// Oracle after BeginPlay: ScriptDispatchObserved==1.
// Extra: empty handle null; pre-BeginPlay 0; RecordDispatch copy independence.
// FixtureIsolated. Keep ScriptDispatchObserved.

UCLASS()
class ATestScriptActorBeginPlayCallsAnotherScriptUFunction : AActor
{
	UPROPERTY()
	int ScriptDispatchObserved = 0;

	UFUNCTION()
	void RecordDispatch()
	{
		ScriptDispatchObserved = 1;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RecordDispatch();
	}
}

bool Observe_ScriptDispatch_EmptyHandleIsNull()
{
	ATestScriptActorBeginPlayCallsAnotherScriptUFunction Actor;
	return Actor == nullptr;
}

int Observe_ScriptDispatch_BeforeBeginPlay(ATestScriptActorBeginPlayCallsAnotherScriptUFunction Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0170 setup: required ATestScriptActorBeginPlayCallsAnotherScriptUFunction is null");
	}
	return Actor.ScriptDispatchObserved;
}

int Observe_ScriptDispatch_DirectRecord(ATestScriptActorBeginPlayCallsAnotherScriptUFunction Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0170 setup: required ATestScriptActorBeginPlayCallsAnotherScriptUFunction is null");
	}
	Actor.RecordDispatch();
	return Actor.ScriptDispatchObserved;
}

bool Observe_ScriptDispatch_CopyIndependence(
	ATestScriptActorBeginPlayCallsAnotherScriptUFunction First,
	ATestScriptActorBeginPlayCallsAnotherScriptUFunction Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0170 setup: required actors are null");
	}
	First.RecordDispatch();
	return First.ScriptDispatchObserved == 1 && Second.ScriptDispatchObserved == 0;
}
