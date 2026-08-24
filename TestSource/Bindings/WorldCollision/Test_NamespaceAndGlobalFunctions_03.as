// Purpose: Observe profile sweep-multi, overlap tests, overlap-multi
// writebacks, and component sweep-multi with a quaternion rotation.
// Runner supplies Start/End or Pos and bExpectHit so hit and miss are exact.
// AS-facing API: System::SweepMultiByProfile; System::OverlapBlockingTestByChannel;
// System::OverlapAnyTestByChannel; System::OverlapAnyTestByObjectType;
// System::OverlapBlockingTestByProfile; System::OverlapAnyTestByProfile;
// System::OverlapMultiByChannel; System::OverlapMultiByObjectType;
// System::OverlapMultiByProfile; System::ComponentSweepMulti (Quat).
// Inputs: Runner-owned Start/End, Pos, FQuat::Identity, MakeSphere(16),
// ECollisionChannel::WorldStatic, n"BlockAll", runner-owned PrimComp,
// DefaultComponentQueryParams, and bExpectHit.
// Boundary/ownership: OutOverlaps/OutHits are caller-owned. PrimComp is not
// owned by the query. FixtureIsolated. SetupOwner=Runner.

namespace TS_WorldCollision_NamespaceAndGlobalFunctions_03
{
	bool Observe_SweepMultiByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		int32 Before = OutHits.Num();
		bool bDefaulted = System::SweepMultiByProfile(OutHits, Start, End, FQuat::Identity, ProfileName, Sphere);
		TArray<FHitResult> ExplicitHits;
		bool bExplicit = System::SweepMultiByProfile(
			ExplicitHits,
			Start,
			End,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_OverlapBlockingTestByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		bool bDefaulted = System::OverlapBlockingTestByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		bool bExplicit = System::OverlapBlockingTestByChannel(
			Start,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_OverlapAnyTestByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		bool bDefaulted = System::OverlapAnyTestByChannel(Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		bool bExplicit = System::OverlapAnyTestByChannel(
			Start,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_OverlapAnyTestByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		bool bDefaulted = System::OverlapAnyTestByObjectType(Start, FQuat::Identity, ObjectQueryParams, Sphere);
		bool bExplicit = System::OverlapAnyTestByObjectType(
			Start,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_OverlapBlockingTestByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		bool bDefaulted = System::OverlapBlockingTestByProfile(Start, FQuat::Identity, ProfileName, Sphere);
		bool bExplicit = System::OverlapBlockingTestByProfile(
			Start,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_OverlapAnyTestByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		bool bDefaulted = System::OverlapAnyTestByProfile(Start, FQuat::Identity, ProfileName, Sphere);
		bool bExplicit = System::OverlapAnyTestByProfile(
			Start,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		return bDefaulted == bExpectHit && bExplicit == bExpectHit;
	}

	bool Observe_OverlapMultiByChannel_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		int32 Before = OutHits.Num();
		bool bDefaulted = System::OverlapMultiByChannel(OutHits, Start, FQuat::Identity, ECollisionChannel::WorldStatic, Sphere);
		TArray<FOverlapResult> ExplicitHits;
		bool bExplicit = System::OverlapMultiByChannel(
			ExplicitHits,
			Start,
			FQuat::Identity,
			ECollisionChannel::Visibility,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam);
		if (bExpectHit)
		{
			return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_OverlapMultiByObjectType_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FCollisionObjectQueryParams ObjectQueryParams(ECollisionChannel::WorldStatic);
		int32 Before = OutHits.Num();
		bool bDefaulted = System::OverlapMultiByObjectType(OutHits, Start, FQuat::Identity, ObjectQueryParams, Sphere);
		TArray<FOverlapResult> ExplicitHits;
		bool bExplicit = System::OverlapMultiByObjectType(
			ExplicitHits,
			Start,
			FQuat::Identity,
			ObjectQueryParams,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_OverlapMultiByProfile_Nominal(const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
	{
		FCollisionShape Sphere = FCollisionShape::MakeSphere(16.0);
		FName ProfileName = n"BlockAll";
		int32 Before = OutHits.Num();
		bool bDefaulted = System::OverlapMultiByProfile(OutHits, Start, FQuat::Identity, ProfileName, Sphere);
		TArray<FOverlapResult> ExplicitHits;
		bool bExplicit = System::OverlapMultiByProfile(
			ExplicitHits,
			Start,
			FQuat::Identity,
			ProfileName,
			Sphere,
			FCollisionQueryParams::DefaultQueryParam);
		if (bExpectHit)
		{
			return bDefaulted && OutHits.Num() > Before && bExplicit && ExplicitHits.Num() > 0;
		}
		return !bDefaulted && OutHits.Num() == Before && !bExplicit && ExplicitHits.Num() == 0;
	}

	bool Observe_ComponentSweepMulti_Nominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		if (PrimComp is null)
		{
			throw("TS_WorldCollision_NamespaceAndGlobalFunctions_03 setup: required PrimComp is null");
		}
		int32 Before = OutHits.Num();
		bool bSwept = System::ComponentSweepMulti(
			OutHits,
			PrimComp,
			Start,
			End,
			FQuat::Identity,
			FComponentQueryParams::DefaultComponentQueryParams);
		if (bExpectHit)
		{
			return bSwept && OutHits.Num() > Before;
		}
		return !bSwept && OutHits.Num() == Before;
	}
}
