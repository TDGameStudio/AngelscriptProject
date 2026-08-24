// Theme: Gameplay.Physics. Value oracle: extended FHitResult index/trace/penetration/reset.
// C++: AngelscriptCoveragePhysicsTests.cpp::HitResultExtendedAccessors
// Oracle: Run() == 1; FaceIndex 7, ElementIndex 2, Item 3, MyItem 4, BoneName CoverageBone,
// PenetrationDepth 4.5, Reset clears blocking/start-penetrating and Time > 0.99.
// Extra: defaults false. DefaultSafe. Keep UPROPERTY names.

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

		return HitResultIndexFieldsRoundTripped
			&& HitResultTraceRangeRoundTripped
			&& HitResultPenetrationRoundTripped
			&& HitResultResetClearedState ? 1 : 0;
	}
}

bool Observe_HitResultExtended_Nominal(UCoveragePhysicsHitResultExtendedHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_HitResultExtendedAccessors setup: required Harness is null");
	}
	return Harness.Run() == 1;
}

bool Observe_HitResultExtended_Defaults(UCoveragePhysicsHitResultExtendedHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_HitResultExtendedAccessors setup: required Harness is null");
	}
	return Harness.HitResultIndexFieldsRoundTripped == false
		&& Harness.HitResultTraceRangeRoundTripped == false
		&& Harness.HitResultPenetrationRoundTripped == false
		&& Harness.HitResultResetClearedState == false;
}

bool Observe_HitResultExtended_EmptyResetBoundary()
{
	FHitResult Hit;
	Hit.Reset();
	return Hit.GetbBlockingHit() == false && Hit.GetbStartPenetrating() == false;
}
