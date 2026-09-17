/**
 * @version v1
 * @summary Observe object-query constructors, the tagged FCollisionQueryParams constructor, and the query flag fields through bIgnoreBlocks.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe object-query constructors, the tagged FCollisionQueryParams constructor, and the query flag fields through bIgnoreBlocks.
 * @topic Baseline
 */
// Runner owns IgnoreActor. A null IgnoreActor is setup failure.
// AS-facing API: FCollisionObjectQueryParams Params();
// FCollisionObjectQueryParams Params(ECollisionChannel QueryChannel);
// FCollisionQueryParams Params(FName InTraceTag, bool bInTraceComplex, const AActor InIgnoreActor);
// FName FCollisionQueryParams.TraceTag; FName FCollisionQueryParams.OwnerTag;
// bool FCollisionQueryParams.bTraceComplex; bool FCollisionQueryParams.bFindInitialOverlaps;
// bool FCollisionQueryParams.bReturnFaceIndex; bool FCollisionQueryParams.bReturnPhysicalMaterial;
// bool FCollisionQueryParams.bIgnoreBlocks;
// Inputs: Empty object query, WorldStatic, n"ConstructorQuery", bInTraceComplex
// true/false, runner-owned IgnoreActor, and null ignore in the diagnostic path.
// Expected observations: Empty object query IsValid is false. Channel query
// is valid. Tagged constructor stores TraceTag and bTraceComplex and ignores
// the live actor. Flag fields round-trip true/false.
// Boundary/ownership: Null InIgnoreActor is skipped. TraceTag is diagnostic.
// SetupOwner=Runner. CleanupOwner=Runner.

namespace TS_FCollisionQueryParams_Behavior_02
{
	// FCollisionObjectQueryParams empty vs WorldStatic, plus tagged FCollisionQueryParams(n"ConstructorQuery", true, IgnoreActor). Oracle: empty invalid, WorldStatic valid, tag stored, ignore Num==1, simple not complex. Runner owns IgnoreActor.
	bool Observe_Params_Nominal(AActor IgnoreActor)
	{
		if (IgnoreActor is null)
		{
			throw("TS_FCollisionQueryParams_Behavior_02 setup: required IgnoreActor is null");
		}
		FCollisionObjectQueryParams Empty;
		FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
		FCollisionQueryParams Tagged(n"ConstructorQuery", true, IgnoreActor);
		FCollisionQueryParams Simple(n"SimpleQuery", false, IgnoreActor);
		return !Empty.IsValid() && WorldStatic.IsValid() && Tagged.TraceTag == n"ConstructorQuery" && Tagged.bTraceComplex && Tagged.GetIgnoredActors().Num() == 1 && Simple.bTraceComplex == false;
	}

	// FCollisionQueryParams.TraceTag default NAME_None, assigned n"TraceTag", then NAME_None. Oracle: assigned then cleared. Diagnostic tag field.
	bool Observe_Surface033_Nominal()
	{
		FCollisionQueryParams Params;
		Params.TraceTag = n"TraceTag";
		FName Assigned = Params.TraceTag;
		Params.TraceTag = NAME_None;
		return Assigned == n"TraceTag" && Params.TraceTag == NAME_None;
	}

	// FCollisionQueryParams.OwnerTag assigned n"OwnerTag" then NAME_None. Oracle: assigned then cleared. Diagnostic tag field.
	bool Observe_Surface034_Nominal()
	{
		FCollisionQueryParams Params;
		Params.OwnerTag = n"OwnerTag";
		FName Assigned = Params.OwnerTag;
		Params.OwnerTag = NAME_None;
		return Assigned == n"OwnerTag" && Params.OwnerTag == NAME_None;
	}

	// FCollisionQueryParams.bTraceComplex true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface035_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bTraceComplex = true;
		bool bSetTrue = Params.bTraceComplex;
		Params.bTraceComplex = false;
		bool bSetFalse = Params.bTraceComplex;
		return bSetTrue && !bSetFalse;
	}

	// FCollisionQueryParams.bFindInitialOverlaps true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface036_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bFindInitialOverlaps = true;
		bool bSetTrue = Params.bFindInitialOverlaps;
		Params.bFindInitialOverlaps = false;
		bool bSetFalse = Params.bFindInitialOverlaps;
		return bSetTrue && !bSetFalse;
	}

	// FCollisionQueryParams.bReturnFaceIndex true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface037_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bReturnFaceIndex = true;
		bool bSetTrue = Params.bReturnFaceIndex;
		Params.bReturnFaceIndex = false;
		bool bSetFalse = Params.bReturnFaceIndex;
		return bSetTrue && !bSetFalse;
	}

	// FCollisionQueryParams.bReturnPhysicalMaterial true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface038_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bReturnPhysicalMaterial = true;
		bool bSetTrue = Params.bReturnPhysicalMaterial;
		Params.bReturnPhysicalMaterial = false;
		bool bSetFalse = Params.bReturnPhysicalMaterial;
		return bSetTrue && !bSetFalse;
	}

	// FCollisionQueryParams.bIgnoreBlocks true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface039_Nominal()
	{
		FCollisionQueryParams Params;
		Params.bIgnoreBlocks = true;
		bool bSetTrue = Params.bIgnoreBlocks;
		Params.bIgnoreBlocks = false;
		bool bSetFalse = Params.bIgnoreBlocks;
		return bSetTrue && !bSetFalse;
	}

	void ExerciseExpectedFailure()
	{
		AActor NullActor;
		FCollisionQueryParams Params(NAME_None, true, NullActor);
		FName Tag = Params.TraceTag;
	}
}
/** @end */
