/**
 * @version v1
 * @summary Observe remaining FComponentQueryParams flags and object-query constructors from init type and packed bits.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FComponentQueryParams flags and object-query constructors from init type and packed bits.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: bool FComponentQueryParams.bReturnPhysicalMaterial;
// bool FComponentQueryParams.bIgnoreBlocks; bool FComponentQueryParams.bIgnoreTouches;
// bool FComponentQueryParams.bSkipNarrowPhase;
// EQueryMobilityType FComponentQueryParams.MobilityType;
// uint8 FComponentQueryParams.IgnoreMask;
// FCollisionEnabledMask FComponentQueryParams.ShapeCollisionMask;
// FCollisionObjectQueryParams Params(ECollisionObjectQueryInitType QueryType);
// FCollisionObjectQueryParams Params(int32 InObjectTypesToQuery);
// int32 FCollisionObjectQueryParams.ObjectTypesToQuery;
// Inputs: true/false flags, Static mobility, IgnoreMask 23, ShapeCollisionMask
// Bits 3, AllObjects/AllStaticObjects/AllDynamicObjects, packed bits 1.
// Expected observations: Flag fields round-trip. Init-type constructors are
// valid. Packed bits 1 is valid and ObjectTypesToQuery is 1.
// Boundary/ownership: ShapeCollisionMask restricts collision-enabled state.
// ObjectTypesToQuery exposes the packed low object-channel bits.

namespace TS_FCollisionQueryParams_Behavior_04
{
	// FComponentQueryParams.bReturnPhysicalMaterial true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface063_Nominal()
	{
		FComponentQueryParams Params;
		Params.bReturnPhysicalMaterial = true;
		bool bSetTrue = Params.bReturnPhysicalMaterial;
		Params.bReturnPhysicalMaterial = false;
		bool bSetFalse = Params.bReturnPhysicalMaterial;
		return bSetTrue && !bSetFalse;
	}

	// FComponentQueryParams.bIgnoreBlocks true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface064_Nominal()
	{
		FComponentQueryParams Params;
		Params.bIgnoreBlocks = true;
		bool bSetTrue = Params.bIgnoreBlocks;
		Params.bIgnoreBlocks = false;
		bool bSetFalse = Params.bIgnoreBlocks;
		return bSetTrue && !bSetFalse;
	}

	// FComponentQueryParams.bIgnoreTouches true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface065_Nominal()
	{
		FComponentQueryParams Params;
		Params.bIgnoreTouches = true;
		bool bSetTrue = Params.bIgnoreTouches;
		Params.bIgnoreTouches = false;
		bool bSetFalse = Params.bIgnoreTouches;
		return bSetTrue && !bSetFalse;
	}

	// FComponentQueryParams.bSkipNarrowPhase true then false. Oracle: true then false. Flag field round-trip.
	bool Observe_Surface066_Nominal()
	{
		FComponentQueryParams Params;
		Params.bSkipNarrowPhase = true;
		bool bSetTrue = Params.bSkipNarrowPhase;
		Params.bSkipNarrowPhase = false;
		bool bSetFalse = Params.bSkipNarrowPhase;
		return bSetTrue && !bSetFalse;
	}

	// FComponentQueryParams.MobilityType assigned Static then Any. Oracle: Static then Any. Enum field.
	bool Observe_Surface067_Nominal()
	{
		FComponentQueryParams Params;
		Params.MobilityType = EQueryMobilityType::Static;
		EQueryMobilityType Assigned = Params.MobilityType;
		Params.MobilityType = EQueryMobilityType::Any;
		return Assigned == EQueryMobilityType::Static && Params.MobilityType == EQueryMobilityType::Any;
	}

	// FComponentQueryParams.IgnoreMask assigned 23 then 0. Oracle: 23 then 0. Packed filter bits.
	bool Observe_Surface068_Nominal()
	{
		FComponentQueryParams Params;
		Params.IgnoreMask = 23;
		uint8 Assigned = Params.IgnoreMask;
		Params.IgnoreMask = 0;
		return Assigned == 23 && Params.IgnoreMask == 0;
	}

	// FComponentQueryParams.ShapeCollisionMask.Bits assigned 3. Oracle: Bits==3. Mask is copied onto the params.
	bool Observe_Surface069_Nominal()
	{
		FComponentQueryParams Params;
		FCollisionEnabledMask Mask = Params.ShapeCollisionMask;
		Mask.Bits = 3;
		Params.ShapeCollisionMask = Mask;
		int8 Assigned = Params.ShapeCollisionMask.Bits;
		return Assigned == 3;
	}

	// FCollisionObjectQueryParams AllObjects/AllStatic/AllDynamic and packed bits 1. Oracle: all valid and ObjectTypesToQuery==1. Init constructors.
	bool Observe_Params_Nominal()
	{
		FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
		FCollisionObjectQueryParams AllStaticObjects(ECollisionObjectQueryInitType::AllStaticObjects);
		FCollisionObjectQueryParams AllDynamicObjects(ECollisionObjectQueryInitType::AllDynamicObjects);
		FCollisionObjectQueryParams Bitfield(1);
		return AllObjects.IsValid() && AllStaticObjects.IsValid() && AllDynamicObjects.IsValid() && Bitfield.IsValid() && Bitfield.ObjectTypesToQuery == 1;
	}

	// FCollisionObjectQueryParams.ObjectTypesToQuery default 0, assigned 1, then 0. Oracle: 0 then 1 then 0. Packed object-channel bits.
	bool Observe_Surface085_Nominal()
	{
		FCollisionObjectQueryParams Params;
		int32 DefaultBits = Params.ObjectTypesToQuery;
		Params.ObjectTypesToQuery = 1;
		int32 Assigned = Params.ObjectTypesToQuery;
		Params.ObjectTypesToQuery = 0;
		return DefaultBits == 0 && Assigned == 1 && Params.ObjectTypesToQuery == 0;
	}
}
/** @end */
