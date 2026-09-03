/**
 * Handle casts between derived, base and unrelated types: upcasting always
 * succeeds, downcasting back succeeds, and casting to an unrelated type yields
 * nullptr.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.HandleCast
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.HandleCast
 * @Provenance C++: AngelscriptCoverageHandleTests.cpp::HandleCast
 * @Provenance sha256=4a8493c1ead77a4311babdf1cfea0f02225ad53b08f5deeb310c74eb7a012e59; lines 264-302.
 * @Provenance Oracle: CastToBaseSucceeded=true; CastToDerivedSucceeded=true; CastToUnrelatedFailed=true.
 * @Provenance Extra: flags default false. FixtureIsolated. Failed Cast returns nullptr.
 */

UCLASS()
class ACoverageHandleCastActor : APawn
{
	UPROPERTY()
	bool CastToBaseSucceeded = false;

	UPROPERTY()
	bool CastToDerivedSucceeded = false;

	UPROPERTY()
	bool CastToUnrelatedFailed = false;

	/**
	 * Runs the upcast, downcast and unrelated-cast sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three flags record their outcome
	 */
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

	/**
	 * Observe that a locally constructed actor has run no cast.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleCastFlagsDefaultToFalse()
	{
		if (CastToBaseSucceeded)
		{
			return false;
		}

		if (CastToDerivedSucceeded)
		{
			return false;
		}

		return !CastToUnrelatedFailed;
	}
}
