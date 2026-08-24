// Theme: Feature.Inheritance. WorldStory script IsValid guard after DestroyActor.
// C++: AngelscriptActorScriptOverrideTests.cpp::DestroyedActorInvocationFailsSafely
// Oracle after destroy + TriggerCallAfterDestroy: FailedSafelyObserved==1, UnexpectedInvocationObserved==0.
// Extra: empty TargetActor; live target still receives 33. FixtureIsolated.
// Keep InvocationValue/TargetActor/FailedSafelyObserved/UnexpectedInvocationObserved.

UCLASS()
class ATestScriptActorDestroyedInvocationTarget : AActor
{
	UPROPERTY()
	int InvocationValue = 0;

	UFUNCTION()
	void ReceiveInvocation(int Value)
	{
		InvocationValue = Value;
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
}

bool Observe_DestroyedInvoke_EmptyHandleIsNull()
{
	ATestScriptActorDestroyedInvocationSource Actor;
	return Actor == nullptr;
}

int Observe_DestroyedInvoke_EmptyTargetFailsSafely(ATestScriptActorDestroyedInvocationSource Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0173 setup: required ATestScriptActorDestroyedInvocationSource is null");
	}
	Actor.TriggerCallAfterDestroy();
	return Actor.FailedSafelyObserved;
}

int Observe_DestroyedInvoke_EmptyTargetDoesNotInvoke(ATestScriptActorDestroyedInvocationSource Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0173 setup: required ATestScriptActorDestroyedInvocationSource is null");
	}
	Actor.TriggerCallAfterDestroy();
	return Actor.UnexpectedInvocationObserved;
}

int Observe_DestroyedInvoke_LiveTargetValue(ATestScriptActorDestroyedInvocationSource Source)
{
	if (Source == nullptr || Source.TargetActor == nullptr)
	{
		throw("TS-FEAT-0173 setup: required live target is null");
	}
	Source.TriggerCallAfterDestroy();
	return Source.TargetActor.InvocationValue;
}
