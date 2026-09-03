/**
 * A script IsValid guard after DestroyActor. C++ destroys the target then calls
 * TriggerCallAfterDestroy and verifies FailedSafelyObserved==1 and
 * UnexpectedInvocationObserved==0. A live target still receives 33.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.DestroyedActorInvocationFailsSafely
 * @Harness UClass
 * @Tag Feature.Inheritance.DestroyedActorInvocationFailsSafely
 * @Provenance Theme: Feature.Inheritance. WorldStory script IsValid guard after DestroyActor.
 * @Provenance C++: AngelscriptActorScriptOverrideTests.cpp::DestroyedActorInvocationFailsSafely
 * @Provenance Oracle after destroy + TriggerCallAfterDestroy: FailedSafelyObserved==1, UnexpectedInvocationObserved==0.
 * @Provenance Extra: empty TargetActor; live target still receives 33. FixtureIsolated.
 * @Provenance Keep InvocationValue/TargetActor/FailedSafelyObserved/UnexpectedInvocationObserved.
 */

UCLASS()
class ATestScriptActorDestroyedInvocationTarget : AActor
{
	UPROPERTY()
	int InvocationValue = 0;

	/**
	 * Store a value received from the source actor.
	 *
	 * @Kind Action
	 * @Covers Inheritance.DestroyedActorInvocationFailsSafely
	 * @Inputs the invocation payload
	 * @Return InvocationValue == Value
	 * @Param Value the payload, 33 when live
	 */
	UFUNCTION()
	void ReceiveInvocation(int Value)
	{
		InvocationValue = Value;
	}

	/**
	 * Observe the default InvocationValue on a locally constructed target.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DestroyedActorInvocationFailsSafely
	 * @Inputs a target that has not been invoked
	 * @Return InvocationValue, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultInvocationValue()
	{
		return InvocationValue;
	}
}

UCLASS()
class ATestScriptActorDestroyedInvocationSource : AActor
{
	UPROPERTY()
	ATestScriptActorDestroyedInvocationTarget TargetActor;

	UPROPERTY()
	int FailedSafelyObserved = 0;

	UPROPERTY()
	int UnexpectedInvocationObserved = 0;

	/**
	 * Call the target only when it is still valid; otherwise record a safe failure.
	 *
	 * @Kind Action
	 * @Covers Inheritance.DestroyedActorInvocationFailsSafely
	 * @Inputs TargetActor, which may have been destroyed
	 * @Return FailedSafelyObserved == 1 when the target is invalid; otherwise InvocationValue == 33
	 */
	UFUNCTION()
	void TriggerCallAfterDestroy()
	{
		if (TargetActor == null || !IsValid(TargetActor))
		{
			FailedSafelyObserved = 1;
			return;
		}

		TargetActor.ReceiveInvocation(33);
		UnexpectedInvocationObserved = 1;
	}

	/**
	 * Observe that an empty target fails safely and does not invoke.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DestroyedActorInvocationFailsSafely
	 * @Inputs TriggerCallAfterDestroy with TargetActor null
	 * @Return FailedSafelyObserved, expected to be 1
	 * @Boundary empty target
	 */
	UFUNCTION()
	int EmptyTargetFailsSafely()
	{
		TriggerCallAfterDestroy();
		return FailedSafelyObserved;
	}

	/**
	 * Observe that an empty target does not set UnexpectedInvocationObserved.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DestroyedActorInvocationFailsSafely
	 * @Inputs TriggerCallAfterDestroy with TargetActor null
	 * @Return UnexpectedInvocationObserved, expected to be 0
	 * @Boundary empty target
	 */
	UFUNCTION()
	int EmptyTargetDoesNotInvoke()
	{
		TriggerCallAfterDestroy();
		return UnexpectedInvocationObserved;
	}

	/**
	 * Observe that a live target still receives 33.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DestroyedActorInvocationFailsSafely
	 * @Inputs TriggerCallAfterDestroy with a live TargetActor
	 * @Return TargetActor.InvocationValue, expected to be 33
	 */
	UFUNCTION()
	int LiveTargetValue()
	{
		if (TargetActor == nullptr)
		{
			throw("DestroyedActorInvocationFailsSafely setup: required live target is null");
		}
		TriggerCallAfterDestroy();
		return TargetActor.InvocationValue;
	}
}
