/**
 * Trace, sweep and overlap function-library dispatch against world blockers. C++
 * calls VerifyTraceFunctionLibraryEntrypointSmoke by name, so that name is part of
 * the contract and is kept verbatim. The observer covers empty hit and overlap arrays
 * before any traces run.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.TraceFunctionLibraryEntrypointSmoke
 * @Harness Function
 * @Tag Gameplay.Physics.TraceFunctionLibraryEntrypointSmoke
 * @Namespace PhysicsTest
 * @Provenance Theme: Gameplay.Physics. Value oracle: trace/sweep/overlap function-library dispatch.
 * @Provenance C++: AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp::TraceFunctionLibraryEntrypointSmoke
 * @Provenance ExpectGlobalInt VerifyTraceFunctionLibraryEntrypointSmoke == 1 with world blockers.
 * @Provenance Extra: empty MultiHits / Overlaps Num 0 before traces. DefaultSafe.
 */

namespace PhysicsTest
{
	/**
	 * Dispatch line, multi-line, object-type sweep and profile overlap queries.
	 *
	 * @Kind Observe
	 * @Covers Physics.TraceFunctionLibraryEntrypointSmoke
	 * @Inputs world blockers along the line and overlap box
	 * @Return 1 when all four queries report hits and both arrays are non-empty, otherwise 0
	 */
	UFUNCTION()
	int VerifyTraceFunctionLibraryEntrypointSmoke()
	{
		FHitResult LineHit;
		FHitResult SweepHit;
		TArray<FHitResult> MultiHits;
		TArray<FOverlapResult> Overlaps;

		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);

		const FCollisionShape SweepShape = FCollisionShape::MakeBox(FVector(30.0f, 30.0f, 30.0f));
		const FCollisionShape OverlapShape = FCollisionShape::MakeBox(FVector(45.0f, 45.0f, 45.0f));

		const bool bLineSingle = System::LineTraceSingleByChannel(
			LineHit,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			ECollisionChannel::ECC_Visibility);

		const bool bLineMulti = System::LineTraceMultiByChannel(
			MultiHits,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			ECollisionChannel::ECC_Visibility);

		const bool bSweep = System::SweepSingleByObjectType(
			SweepHit,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			ObjectQueryParams,
			SweepShape);

		const bool bOverlap = System::OverlapMultiByProfile(
			Overlaps,
			FVector(0.0f, 150.0f, 0.0f),
			FQuat::Identity,
			CollisionProfile::BlockAllDynamic,
			OverlapShape);

		if (!bLineSingle)
		{
			return 0;
		}
		if (!bLineMulti)
		{
			return 0;
		}
		if (!bSweep)
		{
			return 0;
		}
		if (!bOverlap)
		{
			return 0;
		}
		if (MultiHits.Num() <= 0)
		{
			return 0;
		}
		if (Overlaps.Num() <= 0)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that freshly declared hit and overlap arrays are empty.
	 *
	 * @Kind Observe
	 * @Covers Physics.TraceFunctionLibraryEntrypointSmoke
	 * @Inputs newly declared hit and overlap arrays
	 * @Return true when both arrays have Num 0
	 * @Boundary empty arrays
	 */
	UFUNCTION()
	bool EmptyArrays()
	{
		TArray<FHitResult> MultiHits;
		TArray<FOverlapResult> Overlaps;

		if (MultiHits.Num() != 0)
		{
			return false;
		}
		return Overlaps.Num() == 0;
	}
}
