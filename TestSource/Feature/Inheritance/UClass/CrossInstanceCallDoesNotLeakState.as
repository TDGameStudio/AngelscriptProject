/**
 * A cross-instance UFUNCTION call must not leak LocalState. C++ wires TargetActor
 * and after BeginPlay verifies Source LocalState==11 and Target LocalState==29.
 * An empty target leaves LocalState at 11.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.CrossInstanceCallDoesNotLeakState
 * @Harness UClass
 * @Tag Feature.Inheritance.CrossInstanceCallDoesNotLeakState
 * @Provenance Theme: Feature.Inheritance. WorldStory cross-instance UFUNCTION call does not leak LocalState.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::CrossInstanceCallDoesNotLeakState
 * @Provenance Oracle after BeginPlay with TargetActor wired: Source LocalState==11, Target LocalState==29.
 * @Provenance Extra: empty TargetActor; missing Target leaves LocalState at 11; copy independence.
 * @Provenance FixtureIsolated. Keep TargetActor/LocalState.
 */

UCLASS()
class ATestScriptActorCrossInstanceCallDoesNotLeakState : AActor
{
	UPROPERTY()
	ATestScriptActorCrossInstanceCallDoesNotLeakState TargetActor;

	UPROPERTY()
	int LocalState = 0;

	/**
	 * Receive a signal from another instance by writing LocalState to 29.
	 *
	 * @Kind Action
	 * @Covers Inheritance.CrossInstanceCallDoesNotLeakState
	 * @Inputs none
	 * @Return LocalState == 29
	 */
	UFUNCTION()
	void ReceiveSignal()
	{
		LocalState = 29;
	}

	/**
	 * WorldStory: BeginPlay sets LocalState to 11 and optionally signals the target.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.CrossInstanceCallDoesNotLeakState
	 * @Inputs the assigned TargetActor
	 * @Return source LocalState 11; target LocalState 29 when wired
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LocalState = 11;
		if (TargetActor != null)
		{
			TargetActor.ReceiveSignal();
		}
	}

	/**
	 * Observe that a locally constructed actor has no target and zero state.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CrossInstanceCallDoesNotLeakState
	 * @Inputs an actor that has not begun play
	 * @Return true when TargetActor is null and LocalState is 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (TargetActor != nullptr)
		{
			return false;
		}
		return LocalState == 0;
	}

	/**
	 * Observe LocalState after BeginPlay or a direct ReceiveSignal.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CrossInstanceCallDoesNotLeakState
	 * @Inputs the instance whose LocalState is under test
	 * @Return LocalState
	 */
	UFUNCTION()
	int ObservedLocalState()
	{
		return LocalState;
	}

	/**
	 * Observe ReceiveSignal writing LocalState on this instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.CrossInstanceCallDoesNotLeakState
	 * @Inputs ReceiveSignal()
	 * @Return LocalState, expected to be 29
	 */
	UFUNCTION()
	int ReceiveSignalDirect()
	{
		ReceiveSignal();
		return LocalState;
	}
}
