/**
 * @version v1
 * @summary Observe component sweep/overlap multi overloads that take FRotator or FQuat, including channel filters and overlap writebacks.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe component sweep/overlap multi overloads that take FRotator or FQuat, including channel filters and overlap writebacks.
 * @topic Baseline
 */
// Runner supplies Start/End and bExpectHit so hit and miss are exact.
// AS-facing API: System::ComponentSweepMulti (Rotator);
// System::ComponentSweepMultiByChannel (Quat and Rotator);
// System::ComponentOverlapMulti (Quat and Rotator);
// System::ComponentOverlapMultiByChannel (Quat and Rotator).
// Inputs: Runner-owned PrimComp, Start/End, FQuat::Identity, FRotator::ZeroRotator,
// ECollisionChannel::WorldStatic, DefaultComponentQueryParams,
// DefaultObjectQueryParam omitted and explicit, and bExpectHit.
// Boundary/ownership: PrimComp is borrowed. Params have no default on sweep
// multi. Overlap multi may omit Params and ObjectQueryParams.
// FixtureIsolated. SetupOwner=Runner.

namespace TS_WorldCollision_NamespaceAndGlobalFunctions_04
{
	bool Observe_ComponentSweepMulti_Nominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		if (PrimComp is null)
		{
			throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
		}
		int32 Before = OutHits.Num();
		bool bSwept = System::ComponentSweepMulti(
			OutHits,
			PrimComp,
			Start,
			End,
			FRotator::ZeroRotator,
			FComponentQueryParams::DefaultComponentQueryParams);
		if (bExpectHit)
		{
			return bSwept && OutHits.Num() > Before;
		}
		return !bSwept && OutHits.Num() == Before;
	}

	bool Observe_ComponentSweepMultiByChannel_Nominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FHitResult>& OutHits)
	{
		if (PrimComp is null)
		{
			throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
		}
		int32 Before = OutHits.Num();
		bool bQuat = System::ComponentSweepMultiByChannel(
			OutHits,
			PrimComp,
			Start,
			End,
			FQuat::Identity,
			ECollisionChannel::WorldStatic,
			FComponentQueryParams::DefaultComponentQueryParams);
		TArray<FHitResult> RotatorHits;
		bool bRotator = System::ComponentSweepMultiByChannel(
			RotatorHits,
			PrimComp,
			Start,
			End,
			FRotator::ZeroRotator,
			ECollisionChannel::Visibility,
			FComponentQueryParams::DefaultComponentQueryParams);
		if (bExpectHit)
		{
			return bQuat && OutHits.Num() > Before && bRotator && RotatorHits.Num() > 0;
		}
		return !bQuat && OutHits.Num() == Before && !bRotator && RotatorHits.Num() == 0;
	}

	bool Observe_ComponentOverlapMulti_Nominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
	{
		if (PrimComp is null)
		{
			throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
		}
		int32 Before = OutHits.Num();
		bool bQuatDefaulted = System::ComponentOverlapMulti(OutHits, PrimComp, Start, FQuat::Identity);
		TArray<FOverlapResult> QuatExplicit;
		bool bQuatExplicit = System::ComponentOverlapMulti(
			QuatExplicit,
			PrimComp,
			Start,
			FQuat::Identity,
			FComponentQueryParams::DefaultComponentQueryParams,
			FCollisionObjectQueryParams::DefaultObjectQueryParam);
		TArray<FOverlapResult> RotatorHits;
		bool bRotatorDefaulted = System::ComponentOverlapMulti(RotatorHits, PrimComp, Start, FRotator::ZeroRotator);
		TArray<FOverlapResult> RotatorExplicit;
		bool bRotatorExplicit = System::ComponentOverlapMulti(
			RotatorExplicit,
			PrimComp,
			Start,
			FRotator::ZeroRotator,
			FComponentQueryParams::DefaultComponentQueryParams,
			FCollisionObjectQueryParams::DefaultObjectQueryParam);
		if (bExpectHit)
		{
			return bQuatDefaulted && OutHits.Num() > Before && bQuatExplicit && QuatExplicit.Num() > 0 && bRotatorDefaulted && RotatorHits.Num() > 0 && bRotatorExplicit && RotatorExplicit.Num() > 0;
		}
		return !bQuatDefaulted && OutHits.Num() == Before && !bQuatExplicit && QuatExplicit.Num() == 0 && !bRotatorDefaulted && RotatorHits.Num() == 0 && !bRotatorExplicit && RotatorExplicit.Num() == 0;
	}

	bool Observe_ComponentOverlapMultiByChannel_Nominal(UPrimitiveComponent PrimComp, const FVector& Start, const FVector& End, bool bExpectHit, TArray<FOverlapResult>& OutHits)
	{
		if (PrimComp is null)
		{
			throw("TS_WorldCollision_NamespaceAndGlobalFunctions_04 setup: required PrimComp is null");
		}
		int32 Before = OutHits.Num();
		bool bQuatDefaulted = System::ComponentOverlapMultiByChannel(
			OutHits,
			PrimComp,
			Start,
			FQuat::Identity,
			ECollisionChannel::WorldStatic);
		TArray<FOverlapResult> QuatExplicit;
		bool bQuatExplicit = System::ComponentOverlapMultiByChannel(
			QuatExplicit,
			PrimComp,
			Start,
			FQuat::Identity,
			ECollisionChannel::WorldStatic,
			FComponentQueryParams::DefaultComponentQueryParams,
			FCollisionObjectQueryParams::DefaultObjectQueryParam);
		TArray<FOverlapResult> RotatorHits;
		bool bRotatorDefaulted = System::ComponentOverlapMultiByChannel(
			RotatorHits,
			PrimComp,
			Start,
			FRotator::ZeroRotator,
			ECollisionChannel::Visibility);
		TArray<FOverlapResult> RotatorExplicit;
		bool bRotatorExplicit = System::ComponentOverlapMultiByChannel(
			RotatorExplicit,
			PrimComp,
			Start,
			FRotator::ZeroRotator,
			ECollisionChannel::Visibility,
			FComponentQueryParams::DefaultComponentQueryParams,
			FCollisionObjectQueryParams::DefaultObjectQueryParam);
		if (bExpectHit)
		{
			return bQuatDefaulted && OutHits.Num() > Before && bQuatExplicit && QuatExplicit.Num() > 0 && bRotatorDefaulted && RotatorHits.Num() > 0 && bRotatorExplicit && RotatorExplicit.Num() > 0;
		}
		return !bQuatDefaulted && OutHits.Num() == Before && !bQuatExplicit && QuatExplicit.Num() == 0 && !bRotatorDefaulted && RotatorHits.Num() == 0 && !bRotatorExplicit && RotatorExplicit.Num() == 0;
	}
}
/** @end */
