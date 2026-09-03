/**
 * BeginPlay dispatches another script UFUNCTION that writes ScriptDispatchObserved.
 * C++ verifies the count is 1 after BeginPlay. Direct RecordDispatch and copy
 * independence cover the empty and second-instance boundaries.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.BeginPlayCallsAnotherScriptUFunction
 * @Harness UClass
 * @Tag Feature.Inheritance.BeginPlayCallsAnotherScriptUFunction
 * @Provenance Theme: Feature.Inheritance. WorldStory BeginPlay dispatches another script UFUNCTION.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::BeginPlayCallsAnotherScriptUFunction
 * @Provenance Oracle after BeginPlay: ScriptDispatchObserved==1.
 * @Provenance Extra: empty handle null; pre-BeginPlay 0; RecordDispatch copy independence.
 * @Provenance FixtureIsolated. Keep ScriptDispatchObserved.
 */

UCLASS()
class ATestScriptActorBeginPlayCallsAnotherScriptUFunction : AActor
{
	UPROPERTY()
	int ScriptDispatchObserved = 0;

	/**
	 * Record that a script UFUNCTION ran by setting ScriptDispatchObserved to 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BeginPlayCallsAnotherScriptUFunction
	 * @Inputs none
	 * @Return ScriptDispatchObserved == 1
	 */
	UFUNCTION()
	void RecordDispatch()
	{
		ScriptDispatchObserved = 1;
	}

	/**
	 * WorldStory: BeginPlay calls RecordDispatch.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BeginPlayCallsAnotherScriptUFunction
	 * @Inputs none
	 * @Return ScriptDispatchObserved == 1 after BeginPlay
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RecordDispatch();
	}

	/**
	 * Observe that a locally constructed actor has not recorded a dispatch.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BeginPlayCallsAnotherScriptUFunction
	 * @Inputs an actor that has not begun play
	 * @Return true when ScriptDispatchObserved is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultZero()
	{
		return ScriptDispatchObserved == 0;
	}

	/**
	 * Observe RecordDispatch writing ScriptDispatchObserved on this instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BeginPlayCallsAnotherScriptUFunction
	 * @Inputs RecordDispatch()
	 * @Return ScriptDispatchObserved, expected to be 1
	 */
	UFUNCTION()
	int DirectRecord()
	{
		RecordDispatch();
		return ScriptDispatchObserved;
	}

	/**
	 * Observe that recording on this instance leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BeginPlayCallsAnotherScriptUFunction
	 * @Inputs this actor plus a second actor
	 * @Return true when this is 1 and the other stays 0
	 * @Param Second the other actor, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestScriptActorBeginPlayCallsAnotherScriptUFunction Second)
	{
		if (Second == nullptr)
		{
			throw("BeginPlayCallsAnotherScriptUFunction setup: required Second is null");
		}
		RecordDispatch();
		if (ScriptDispatchObserved != 1)
		{
			return false;
		}
		return Second.ScriptDispatchObserved == 0;
	}
}
