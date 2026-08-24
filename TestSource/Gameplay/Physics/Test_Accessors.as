// Theme: Gameplay.Physics. Value oracle: FHitResult function-library populate/reset masks.
// C++: AngelscriptHitResultFunctionLibraryTests.cpp::Accessors
// Oracle: PopulateHitResult == 0 with valid actor/component; ResetHitResult == 0.
// Extra: empty FHitResult Reset == 0; null actor/component populate mask 4|8|16 == 28. DefaultSafe.

int PopulateHitResult(FHitResult& OutHit, AActor ExpectedActor, UPrimitiveComponent ExpectedComponent)
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

	OutHit.SetActor(ExpectedActor);
	AActor RetrievedActor = OutHit.GetActor();
	if (!IsValid(RetrievedActor))
	{
		MismatchMask |= 4;
	}

	OutHit.SetComponent(ExpectedComponent);
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

int ResetHitResult(FHitResult& Hit)
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

bool Observe_ResetHitResult_EmptyDefault()
{
	FHitResult Hit;
	return ResetHitResult(Hit) == 0;
}

bool Observe_PopulateHitResult_NullBoundary()
{
	FHitResult Hit;
	return PopulateHitResult(Hit, nullptr, nullptr) == 28;
}
