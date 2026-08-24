// Theme: Gameplay.Physics. Value oracle: trace/sweep/overlap function-library dispatch.
// C++: AngelscriptWorldCollisionFunctionLibraryTraceTests.cpp::TraceFunctionLibraryEntrypointSmoke
// ExpectGlobalInt VerifyTraceFunctionLibraryEntrypointSmoke == 1 with world blockers.
// Extra: empty MultiHits / Overlaps Num 0 before traces. DefaultSafe.

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

	return bLineSingle
		&& bLineMulti
		&& bSweep
		&& bOverlap
		&& MultiHits.Num() > 0
		&& Overlaps.Num() > 0 ? 1 : 0;
}

bool Observe_TraceFunctionLibraryEntrypointSmoke_Nominal()
{
	return VerifyTraceFunctionLibraryEntrypointSmoke() == 1;
}

bool Observe_TraceFunctionLibraryEntrypointSmoke_EmptyArrays()
{
	TArray<FHitResult> MultiHits;
	TArray<FOverlapResult> Overlaps;
	return MultiHits.Num() == 0 && Overlaps.Num() == 0;
}
