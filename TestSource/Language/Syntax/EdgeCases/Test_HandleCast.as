// Theme: Language.Syntax.EdgeCases. WorldStory Cast derived/base/unrelated handles.
// C++: AngelscriptCoverageHandleTests.cpp::HandleCast
// sha256=4a8493c1ead77a4311babdf1cfea0f02225ad53b08f5deeb310c74eb7a012e59; lines 264-302.
// Oracle: CastToBaseSucceeded=true; CastToDerivedSucceeded=true; CastToUnrelatedFailed=true.
// Extra: flags default false. FixtureIsolated. Failed Cast returns nullptr.

UCLASS()
class ACoverageHandleCastActor : APawn
{
	UPROPERTY()
	bool CastToBaseSucceeded = false;

	UPROPERTY()
	bool CastToDerivedSucceeded = false;

	UPROPERTY()
	bool CastToUnrelatedFailed = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Cast derived to base (always succeeds)
		AActor ActorRef = Cast<AActor>(this);
		if (ActorRef != nullptr)
		{
			CastToBaseSucceeded = true;
		}

		// Cast base back to derived (should succeed since it's actually a Pawn)
		APawn PawnRef = Cast<APawn>(ActorRef);
		if (PawnRef != nullptr)
		{
			CastToDerivedSucceeded = true;
		}

		// Cast to unrelated type (should fail)
		APlayerController ControllerRef = Cast<APlayerController>(this);
		if (ControllerRef == nullptr)
		{
			CastToUnrelatedFailed = true;
		}
	}
}

bool Observe_HandleCast_DefaultFalse(ACoverageHandleCastActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleCast setup: required Actor is null");
	}
	return !Actor.CastToBaseSucceeded && !Actor.CastToDerivedSucceeded && !Actor.CastToUnrelatedFailed;
}
