/**
 * @version v1
 * @summary Extended FHitResult index, trace-range, penetration and reset accessors. C++ treats Run() == 1 as the oracle, so the UCLASS, UFUNCTION and UPROPERTY names are part of the contract and are kept verbatim. The observers.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Extended FHitResult index, trace-range, penetration and reset accessors. C++ treats Run() == 1 as the oracle, so the UCLASS, UFUNCTION and UPROPERTY names are part of the contract and are kept verbatim. The observers.
 * @topic Baseline
 */
UCLASS()
class UCoveragePhysicsHitResultExtendedHarness : UObject
{
	UPROPERTY()
	bool HitResultIndexFieldsRoundTripped = false;

	UPROPERTY()
	bool HitResultTraceRangeRoundTripped = false;

	UPROPERTY()
	bool HitResultPenetrationRoundTripped = false;

	UPROPERTY()
	bool HitResultResetClearedState = false;

	/**
	 * Write index, bone, trace-range and penetration fields, then reset the hit.
	 *
	 * @Kind Action
	 * @Covers Physics.HitResultExtendedAccessors
	 * @Inputs none
	 * @Return 1 when HitResultIndexFieldsRoundTripped, HitResultTraceRangeRoundTripped,
	 * HitResultPenetrationRoundTripped and HitResultResetClearedState are true, otherwise 0
	 */
	UFUNCTION()
	int Run()
	{
		FHitResult Hit(FVector(-10.0f, 0.0f, 0.0f), FVector(10.0f, 0.0f, 0.0f));
		Hit.SetBlockingHit(true);
		Hit.SetbStartPenetrating(true);
		Hit.PenetrationDepth = 4.5f;
		Hit.FaceIndex = 7;
		Hit.ElementIndex = 2;
		Hit.Item = 3;
		Hit.MyItem = 4;
		Hit.BoneName = n"CoverageBone";
		Hit.MyBoneName = n"CoverageMyBone";
		Hit.TraceStart = FVector(-20.0f, 1.0f, 2.0f);
		Hit.TraceEnd = FVector(30.0f, 3.0f, 4.0f);

		HitResultIndexFieldsRoundTripped =
			Hit.FaceIndex == 7
			&& Hit.ElementIndex == 2
			&& Hit.Item == 3
			&& Hit.MyItem == 4
			&& Hit.BoneName == n"CoverageBone"
			&& Hit.MyBoneName == n"CoverageMyBone";

		HitResultTraceRangeRoundTripped =
			Hit.TraceStart.Equals(FVector(-20.0f, 1.0f, 2.0f), 0.01f)
			&& Hit.TraceEnd.Equals(FVector(30.0f, 3.0f, 4.0f), 0.01f);

		HitResultPenetrationRoundTripped =
			Hit.GetbBlockingHit()
			&& Hit.GetbStartPenetrating()
			&& Hit.PenetrationDepth > 4.49f
			&& Hit.PenetrationDepth < 4.51f;

		Hit.Reset();
		HitResultResetClearedState =
			!Hit.GetbBlockingHit()
			&& !Hit.GetbStartPenetrating()
			&& Hit.Time > 0.99f;

		if (!HitResultIndexFieldsRoundTripped)
		{
			return 0;
		}
		if (!HitResultTraceRangeRoundTripped)
		{
			return 0;
		}
		if (!HitResultPenetrationRoundTripped)
		{
			return 0;
		}
		if (!HitResultResetClearedState)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that Run returns 1 after the four flags are written.
	 *
	 * @Kind Observe
	 * @Covers Physics.HitResultExtendedAccessors
	 * @Inputs none
	 * @Return true when Run returns 1
	 */
	UFUNCTION()
	bool RunReturnsOne()
	{
		return Run() == 1;
	}

	/**
	 * Observe that an untouched harness holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.HitResultExtendedAccessors
	 * @Inputs a harness that has not run
	 * @Return true when HitResultIndexFieldsRoundTripped, HitResultTraceRangeRoundTripped,
	 * HitResultPenetrationRoundTripped and HitResultResetClearedState are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (HitResultIndexFieldsRoundTripped)
		{
			return false;
		}
		if (HitResultTraceRangeRoundTripped)
		{
			return false;
		}
		if (HitResultPenetrationRoundTripped)
		{
			return false;
		}
		return HitResultResetClearedState == false;
	}

	/**
	 * Observe that resetting an empty hit result clears blocking and start-penetrating.
	 *
	 * @Kind Observe
	 * @Covers Physics.HitResultExtendedAccessors
	 * @Inputs a default-constructed hit result
	 * @Return true when both flags are false after Reset
	 * @Boundary empty reset
	 */
	UFUNCTION()
	bool EmptyResetBoundary()
	{
		FHitResult Hit;
		Hit.Reset();

		if (Hit.GetbBlockingHit())
		{
			return false;
		}
		return Hit.GetbStartPenetrating() == false;
	}
}
/** @end */
