/**
 * @version v1
 * @summary Observe EAsyncTraceType enumerators and synchronous line-trace test/single/multi queries, including OutHit writeback.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe EAsyncTraceType enumerators and synchronous line-trace test/single/multi queries, including OutHit writeback.
 * @topic Baseline
 */
// Runner supplies Start/End and bExpectHit so hit and miss are exact, not
// "either outcome".
// AS-facing API: EAsyncTraceType::Test; EAsyncTraceType::Single;
// EAsyncTraceType::Multi; System::LineTraceTestByChannel;
// System::LineTraceTestByObjectType; System::LineTraceTestByProfile;
// System::LineTraceSingleByChannel; System::LineTraceSingleByObjectType;
// System::LineTraceSingleByProfile; System::LineTraceMultiByChannel.
// Inputs: Runner-owned Start/End, ECollisionChannel::WorldStatic, Visibility,
// ObjectQueryParams(WorldStatic), n"BlockAll", and bExpectHit.
// Boundary/ownership: OutHit/OutHits are caller-owned writebacks.
// FixtureIsolated. SetupOwner=Runner.

namespace TS_WorldCollision_NamespaceAndGlobalFunctions_01
{
	// EAsyncTraceType::Test is distinct from Single.
	bool Observe_Surface002_Nominal()
	{
		return EAsyncTraceType::Test != EAsyncTraceType::Single;
	}

	// EAsyncTraceType::Single is distinct from Multi.
	bool Observe_Surface003_Nominal()
	{
		return EAsyncTraceType::Single != EAsyncTraceType::Multi;
	}

	// EAsyncTraceType::Multi is distinct from Test.
	bool Observe_Surface004_Nominal()
	{
		return EAsyncTraceType::Multi != EAsyncTraceType::Test;
	}

	// LineTraceTestByChannel default WorldStatic vs explicit Visibility; both must equal bExpectHit.
	bool Observe_LineTraceTestByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		bool bDefaulted = System::LineTraceTestByChannel(Start, End, ECollisionChannel::WorldStatic);
		bool bExplicit = System::LineTraceTestByChannel(
			Start,
			End,
			ECollisionChannel::Visibility,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	// LineTraceTestByObjectType WorldStatic object query; both overloads equal bExpectHit.
	bool Observe_LineTraceTestByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		bool bDefaulted = System::LineTraceTestByObjectType(Start, End, ObjectQueryParams);
		bool bExplicit = System::LineTraceTestByObjectType(Start, End, ObjectQueryParams, FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	// LineTraceTestByProfile BlockAll; default and explicit params both equal bExpectHit.
	bool Observe_LineTraceTestByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FName ProfileName = n"BlockAll";
		bool bDefaulted = System::LineTraceTestByProfile(Start, End, ProfileName);
		bool bExplicit = System::LineTraceTestByProfile(Start, End, ProfileName, FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	// LineTraceSingleByChannel writes OutHit. Hit requires blocking; miss requires no blocking.
	bool Observe_LineTraceSingleByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
	{
		bool bHit = System::LineTraceSingleByChannel(OutHit, Start, End, ECollisionChannel::WorldStatic);
		FHitResult ExplicitHit;
		bool bExplicit = System::LineTraceSingleByChannel(
			ExplicitHit,
			Start,
			End,
			ECollisionChannel::Visibility,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		if (bExpectHit)
		{
			return bHit && OutHit.GetbBlockingHit() && bExplicit && ExplicitHit.GetbBlockingHit();
		}
		return !bHit && !OutHit.GetbBlockingHit() && !bExplicit && !ExplicitHit.GetbBlockingHit();
	}

	// LineTraceSingleByObjectType writes OutHit. Hit vs miss are distinct blocking expectations.
	bool Observe_LineTraceSingleByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
	{
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		bool bHit = System::LineTraceSingleByObjectType(OutHit, Start, End, ObjectQueryParams);
		FHitResult ExplicitHit;
		bool bExplicit = System::LineTraceSingleByObjectType(
			ExplicitHit,
			Start,
			End,
			ObjectQueryParams,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bHit && OutHit.GetbBlockingHit() && bExplicit;
		}
		return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
	}

	// LineTraceSingleByProfile BlockAll writes OutHit. Hit vs miss are distinct blocking expectations.
	bool Observe_LineTraceSingleByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, FHitResult& OutHit)
	{
		FName ProfileName = n"BlockAll";
		bool bHit = System::LineTraceSingleByProfile(OutHit, Start, End, ProfileName);
		FHitResult ExplicitHit;
		bool bExplicit = System::LineTraceSingleByProfile(
			ExplicitHit,
			Start,
			End,
			ProfileName,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bHit && OutHit.GetbBlockingHit() && bExplicit;
		}
		return !bHit && !OutHit.GetbBlockingHit() && !bExplicit;
	}

	// LineTraceMultiByChannel appends OutHits. Hit grows the array; miss leaves the count unchanged.
	bool Observe_LineTraceMultiByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		int32 Before = OutHits.Num();
		bool bHit = System::LineTraceMultiByChannel(OutHits, Start, End, ECollisionChannel::WorldStatic);
		TArray<FHitResult> ExplicitHits;
		bool bExplicit = System::LineTraceMultiByChannel(
			ExplicitHits,
			Start,
			End,
			ECollisionChannel::Visibility,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		if (bExpectHit)
		{
			return bHit && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bHit && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}
}
/** @end */
