// Purpose: Observe remaining FCollisionQueryParams flags and the tagged
// FComponentQueryParams constructor plus its early flag fields.
// Runner owns IgnoreActor. A null IgnoreActor is setup failure.
// AS-facing API: bool FCollisionQueryParams.bIgnoreTouches;
// bool FCollisionQueryParams.bSkipNarrowPhase;
// EQueryMobilityType FCollisionQueryParams.MobilityType;
// uint8 FCollisionQueryParams.IgnoreMask;
// FComponentQueryParams Params(FName InTraceTag, const AActor InIgnoreActor, FCollisionEnabledMask CollisionEnabledMask);
// FName FComponentQueryParams.TraceTag; FName FComponentQueryParams.OwnerTag;
// bool FComponentQueryParams.bTraceComplex; bool FComponentQueryParams.bFindInitialOverlaps;
// bool FComponentQueryParams.bReturnFaceIndex;
// Inputs: true/false flags, EQueryMobilityType::Dynamic, IgnoreMask 17,
// n"ConstructorComponent", runner-owned IgnoreActor, QueryOnly mask.
// Expected observations: Flag fields round-trip. MobilityType stores Dynamic.
// Tagged component constructor stores TraceTag and ShapeCollisionMask.Bits.
// Boundary/ownership: CollisionEnabledMask restricts allowed collision modes.
// Null InIgnoreActor is skipped. SetupOwner=Runner. CleanupOwner=Runner.

namespace TS_FCollisionQueryParams_Behavior_03
{
	// FCollisionQueryParams.bIgnoreTouches true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface040_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bIgnoreTouches = true;
		bool bSetTrue = Params.bIgnoreTouches;
		Params.bIgnoreTouches = false;
		bool bSetFalse = Params.bIgnoreTouches;
		return bSetTrue && !bSetFalse;
	}

	// FCollisionQueryParams.bSkipNarrowPhase true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface041_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bSkipNarrowPhase = true;
		bool bSetTrue = Params.bSkipNarrowPhase;
		Params.bSkipNarrowPhase = false;
		bool bSetFalse = Params.bSkipNarrowPhase;
		return bSetTrue && !bSetFalse;
	}

	// FCollisionQueryParams.MobilityType default Any, assigned Dynamic, then Static. Oracle: Any then Dynamic then Static. Enum field.
	bool Observe_Surface042_Nominal()
	{
		FCollisionQueryParams Params;
		EQueryMobilityType DefaultType = Params.MobilityType;
		Params.MobilityType = EQueryMobilityType::Dynamic;
		EQueryMobilityType Assigned = Params.MobilityType;
		Params.MobilityType = EQueryMobilityType::Static;
		return Assigned == EQueryMobilityType::Dynamic && Params.MobilityType == EQueryMobilityType::Static && DefaultType == EQueryMobilityType::Any;
	}

	// FCollisionQueryParams.IgnoreMask default 0, assigned 17, then 0. Oracle: 0 then 17 then 0. Packed filter bits.
	bool Observe_Surface043_Nominal()
	{
		FCollisionQueryParams Params;
		uint8 DefaultMask = Params.IgnoreMask;
		Params.IgnoreMask = 17;
		uint8 Assigned = Params.IgnoreMask;
		Params.IgnoreMask = 0;
		return DefaultMask == 0 && Assigned == 17 && Params.IgnoreMask == 0;
	}

	// FComponentQueryParams(n"ConstructorComponent", IgnoreActor, QueryOnly). Oracle: tag stored, mask Bits match, ignore Num==1, null skip Num==0. Runner owns IgnoreActor.
	bool Observe_Params_Nominal(AActor IgnoreActor)
	{
		if (IgnoreActor is null)
		{
			throw("TS_FCollisionQueryParams_Behavior_03 setup: required IgnoreActor is null");
		}
		FCollisionEnabledMask QueryOnlyMask(ECollisionEnabled::QueryOnly);
		FComponentQueryParams Params(n"ConstructorComponent", IgnoreActor, QueryOnlyMask);
		AActor NullActor;
		FCollisionEnabledMask EmptyMask;
		FComponentQueryParams NullIgnore(n"NullIgnore", NullActor, EmptyMask);
		return Params.TraceTag == n"ConstructorComponent" && Params.ShapeCollisionMask.Bits == QueryOnlyMask.Bits && Params.GetIgnoredActors().Num() == 1 && NullIgnore.GetIgnoredActors().Num() == 0;
	}

	// FComponentQueryParams.TraceTag assigned n"ComponentTrace" then NAME_None. Oracle: assigned then cleared. Diagnostic tag field.
	bool Observe_Surface058_Nominal()
	{
		FComponentQueryParams Params;
		Params.TraceTag = n"ComponentTrace";
		FName Assigned = Params.TraceTag;
		Params.TraceTag = NAME_None;
		return Assigned == n"ComponentTrace" && Params.TraceTag == NAME_None;
	}

	// FComponentQueryParams.OwnerTag assigned n"ComponentOwner" then NAME_None. Oracle: assigned then cleared. Diagnostic tag field.
	bool Observe_Surface059_Nominal()
	{
		FComponentQueryParams Params;
		Params.OwnerTag = n"ComponentOwner";
		FName Assigned = Params.OwnerTag;
		Params.OwnerTag = NAME_None;
		return Assigned == n"ComponentOwner" && Params.OwnerTag == NAME_None;
	}

	// FComponentQueryParams.bTraceComplex true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface060_Nominal()
	{
		FComponentQueryParams Params;
		Params.bTraceComplex = true;
		bool bSetTrue = Params.bTraceComplex;
		Params.bTraceComplex = false;
		bool bSetFalse = Params.bTraceComplex;
		return bSetTrue && !bSetFalse;
	}

	// FComponentQueryParams.bFindInitialOverlaps true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface061_Nominal()
	{
		FComponentQueryParams Params;
		Params.bFindInitialOverlaps = true;
		bool bSetTrue = Params.bFindInitialOverlaps;
		Params.bFindInitialOverlaps = false;
		bool bSetFalse = Params.bFindInitialOverlaps;
		return bSetTrue && !bSetFalse;
	}

	// FComponentQueryParams.bReturnFaceIndex true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface062_Nominal()
	{
		FComponentQueryParams Params;
		Params.bReturnFaceIndex = true;
		bool bSetTrue = Params.bReturnFaceIndex;
		Params.bReturnFaceIndex = false;
		bool bSetFalse = Params.bReturnFaceIndex;
		return bSetTrue && !bSetFalse;
	}

	void ExerciseExpectedFailure()
	{
		AActor NullActor;
		FCollisionEnabledMask EmptyMask;
		FComponentQueryParams Params(NAME_None, NullActor, EmptyMask);
		FName Tag = Params.TraceTag;
	}
}
