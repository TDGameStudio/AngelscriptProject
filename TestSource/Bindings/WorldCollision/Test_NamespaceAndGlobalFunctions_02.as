// Purpose: Observe remaining line-trace multi queries and sweep test/single/
// multi queries, including OutHit and OutHits writeback.
// Runner supplies Start/End and bExpectHit so hit and miss are exact, not
// "either outcome".
// AS-facing API: System::LineTraceMultiByObjectType; System::LineTraceMultiByProfile;
// System::SweepTestByChannel; System::SweepTestByObjectType;
// System::SweepTestByProfile; System::SweepSingleByChannel;
// System::SweepSingleByObjectType; System::SweepSingleByProfile;
// System::SweepMultiByChannel; System::SweepMultiByObjectType.
// Inputs: Runner-owned Start/End, FQuat::Identity, MakeSphere(16),
// ECollisionChannel::WorldStatic, ObjectQueryParams(WorldStatic), n"BlockAll",
// and bExpectHit.
// Boundary/ownership: CollisionShape is copied into the query. Out arrays are
// caller-owned. FixtureIsolated. SetupOwner=Runner.

namespace TS_WorldCollision_NamespaceAndGlobalFunctions_02
{
	bool Observe_LineTraceMultiByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		int32 Before = OutHits.Num();
		bool bDefaulted = System::LineTraceMultiByObjectType(OutHits, Start, End, ObjectQueryParams);
		TArray<FHitResult> ExplicitHits;
		bool bExplicit = System::LineTraceMultiByObjectType(
			ExplicitHits,
			Start,
			End,
			ObjectQueryParams,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_LineTraceMultiByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		FName ProfileName = n"BlockAll";
		int32 Before = OutHits.Num();
		bool bDefaulted = System::LineTraceMultiByProfile(OutHits, Start, End, ProfileName);
		TArray<FHitResult> ExplicitHits;
		bool bExplicit = System::LineTraceMultiByProfile(
			ExplicitHits,
			Start,
			End,
			ProfileName,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_SweepTestByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		bool bDefaulted = System::SweepTestByChannel(Start, End, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		bool bExplicit = System::SweepTestByChannel(
			Start,
			End,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_SweepTestByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		bool bDefaulted = System::SweepTestByObjectType(Start, End, FQuat::Identity, ObjectQueryParams, Sphere);
		bool bExplicit = System::SweepTestByObjectType(
			Start,
			End,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_SweepTestByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		bool bDefaulted = System::SweepTestByProfile(Start, End, FQuat::Identity, ProfileName, Sphere);
		bool bExplicit = System::SweepTestByProfile(
			Start,
			End,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_SweepSingleByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		bool bHit = System::SweepSingleByChannel(OutHit, Start, End, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		FHitResult ExplicitHit;
		bool bExplicit = System::SweepSingleByChannel(
			ExplicitHit,
			Start,
			End,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		if (bExpectHit)
		{
			return bHit && OutHit.GetbBlockingHit() && bExplicit && ExplicitHit.GetbBlockingHit();
		}
		return !bHit && !OutHit.GetbBlockingHit() && !bExplicit && !ExplicitHit.GetbBlockingHit();
	}

	bool Observe_SweepSingleByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		bool bHit = System::SweepSingleByObjectType(OutHit, Start, End, FQuat::Identity, ObjectQueryParams, Sphere);
		FHitResult ExplicitHit;
		bool bExplicit = System::SweepSingleByObjectType(
			ExplicitHit,
			Start,
			End,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bHit && OutHit.GetbBlockingHit() && bExplicit;
		}
		return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
	}

	bool Observe_SweepSingleByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		bool bHit = System::SweepSingleByProfile(OutHit, Start, End, FQuat::Identity, ProfileName, Sphere);
		FHitResult ExplicitHit;
		bool bExplicit = System::SweepSingleByProfile(
			ExplicitHit,
			Start,
			End,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bHit && OutHit.GetbBlockingHit() && bExplicit;
		}
		return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
	}

	bool Observe_SweepMultiByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		int32 Before = OutHits.Num();
		bool bHit = System::SweepMultiByChannel(OutHits, Start, End, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		TArray<FHitResult> ExplicitHits;
		bool bExplicit = System::SweepMultiByChannel(
			ExplicitHits,
			Start,
			End,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		if (bExpectHit)
		{
			return bHit && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bHit && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_SweepMultiByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		int32 Before = OutHits.Num();
		bool bHit = System::SweepMultiByObjectType(OutHits, Start, End, FQuat::Identity, ObjectQueryParams, Sphere);
		TArray<FHitResult> ExplicitHits;
		bool bExplicit = System::SweepMultiByObjectType(
			ExplicitHits,
			Start,
			End,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bHit && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bHit && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}
}
