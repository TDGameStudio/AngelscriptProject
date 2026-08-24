// Theme: Feature.Inheritance. WorldStory cross-instance UFUNCTION call does not leak LocalState.
// C++: AngelscriptActorScriptOverrideTests.cpp::CrossInstanceCallDoesNotLeakState
// Oracle after BeginPlay with TargetActor wired: Source LocalState==11, Target LocalState==29.
// Extra: empty TargetActor; missing Target leaves LocalState at 11; copy independence.
// FixtureIsolated. Keep TargetActor/LocalState.

UCLASS()
class ATestScriptActorCrossInstanceCallDoesNotLeakState : AActor
{
	UPROPERTY()
	ATestScriptActorCrossInstanceCallDoesNotLeakState TargetActor;

	UPROPERTY()
	int LocalState = 0;

	UFUNCTION()
	void ReceiveSignal()
	{
		LocalState = 29;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LocalState = 11;
		if (TargetActor != null)
		{
			TargetActor.ReceiveSignal();
		}
	}
}

bool Observe_CrossInstance_EmptyHandleIsNull()
{
	ATestScriptActorCrossInstanceCallDoesNotLeakState Actor;
	return Actor == nullptr;
}

bool Observe_CrossInstance_EmptyTargetDefault(ATestScriptActorCrossInstanceCallDoesNotLeakState Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0172 setup: required ATestScriptActorCrossInstanceCallDoesNotLeakState is null");
	}
	return Actor.TargetActor == nullptr && Actor.LocalState == 0;
}

int Observe_CrossInstance_SourceAfterBeginPlay(ATestScriptActorCrossInstanceCallDoesNotLeakState Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0172 setup: required source actor is null");
	}
	return Actor.LocalState;
}

int Observe_CrossInstance_TargetAfterBeginPlay(ATestScriptActorCrossInstanceCallDoesNotLeakState Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0172 setup: required target actor is null");
	}
	return Actor.LocalState;
}

int Observe_CrossInstance_ReceiveSignalDirect(ATestScriptActorCrossInstanceCallDoesNotLeakState Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0172 setup: required ATestScriptActorCrossInstanceCallDoesNotLeakState is null");
	}
	Actor.ReceiveSignal();
	return Actor.LocalState;
}
