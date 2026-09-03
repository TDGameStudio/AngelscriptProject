/**
 * FHitResult function-library populate and reset masks. C++ calls both entrypoints
 * by name, so those names are part of the contract and are kept verbatim. The
 * observers cover an empty reset and a null actor/component populate.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.Accessors
 * @Harness Function
 * @Tag Gameplay.Physics.Accessors
 * @Namespace PhysicsTest
 * @Provenance Theme: Gameplay.Physics. Value oracle: FHitResult function-library populate/reset masks.
 * @Provenance C++: AngelscriptHitResultFunctionLibraryTests.cpp::Accessors
 * @Provenance Oracle: PopulateHitResult == 0 with valid actor/component; ResetHitResult == 0.
 * @Provenance Extra: empty FHitResult Reset == 0; null actor/component populate mask 4|8|16 == 28. DefaultSafe.
 */

namespace PhysicsTest
{
	/**
	 * Populate a hit result with a baseline actor and component, then flip blocking
	 * and start-penetrating flags, returning a mismatch mask.
	 *
	 * @Kind Action
	 * @Covers Physics.Accessors
	 * @Inputs an inout hit, a baseline actor and a baseline component
	 * @Return the mismatch mask; 0 when populate succeeds
	 * @Param OutHit the hit result to populate
	 * @Param BaselineActor the actor written onto the hit
	 * @Param BaselineComponent the component written onto the hit
	 */
	UFUNCTION()
	int PopulateHitResult(FHitResult&inout OutHit, AActor BaselineActor, UPrimitiveComponent BaselineComponent)
	{
		int MismatchMask = 0;

		if (OutHit.GetbBlockingHit())
		{
			MismatchMask |= 1;
		}
		if (OutHit.GetbStartPenetrating())
		{
			MismatchMask |= 2;
		}

		OutHit.SetActor(BaselineActor);
		AActor RetrievedActor = OutHit.GetActor();
		if (!IsValid(RetrievedActor))
		{
			MismatchMask |= 4;
		}

		OutHit.SetComponent(BaselineComponent);
		AActor RetrievedActorAfterComponent = OutHit.GetActor();
		if (!IsValid(RetrievedActorAfterComponent))
		{
			MismatchMask |= 8;
		}

		UPrimitiveComponent RetrievedComponent = OutHit.GetComponent();
		if (!IsValid(RetrievedComponent))
		{
			MismatchMask |= 16;
		}

		OutHit.SetBlockingHit(true);
		if (!OutHit.GetbBlockingHit())
		{
			MismatchMask |= 32;
		}

		OutHit.SetbBlockingHit(false);
		if (OutHit.GetbBlockingHit())
		{
			MismatchMask |= 64;
		}

		OutHit.SetbStartPenetrating(true);
		if (!OutHit.GetbStartPenetrating())
		{
			MismatchMask |= 128;
		}

		return MismatchMask;
	}

	/**
	 * Reset a hit result and report whether blocking and start-penetrating stayed clear.
	 *
	 * @Kind Action
	 * @Covers Physics.Accessors
	 * @Inputs a hit result
	 * @Return the mismatch mask; 0 when reset clears both flags
	 * @Param Hit the hit result to reset
	 */
	UFUNCTION()
	int ResetHitResult(FHitResult&inout Hit)
	{
		int MismatchMask = 0;

		Hit.Reset();
		if (Hit.GetbBlockingHit())
		{
			MismatchMask |= 1;
		}
		if (Hit.GetbStartPenetrating())
		{
			MismatchMask |= 2;
		}

		return MismatchMask;
	}

	/**
	 * Observe that resetting an empty hit result yields a zero mismatch mask.
	 *
	 * @Kind Observe
	 * @Covers Physics.Accessors
	 * @Inputs a default-constructed hit result
	 * @Return true when ResetHitResult returns 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ResetHitResultEmptyDefault()
	{
		FHitResult Hit;
		return ResetHitResult(Hit) == 0;
	}

	/**
	 * Observe that populating with a null actor and component sets bits 4, 8 and 16.
	 *
	 * @Kind Observe
	 * @Covers Physics.Accessors
	 * @Inputs a default-constructed hit result plus null actor and component
	 * @Return true when PopulateHitResult returns 28
	 * @Boundary null actor and component
	 */
	UFUNCTION()
	bool PopulateHitResultNullBoundary()
	{
		FHitResult Hit;
		return PopulateHitResult(Hit, nullptr, nullptr) == 28;
	}
}
