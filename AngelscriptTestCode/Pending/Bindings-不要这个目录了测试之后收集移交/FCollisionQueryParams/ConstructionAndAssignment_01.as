/**
 * @version v1
 * @summary Observe collision-query enums/structs and assignment of query and component parameter objects. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe collision-query enums/structs and assignment of query and component parameter objects. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// struct FCollisionQueryParams; struct FCollisionEnabledMask;
// struct FComponentQueryParams; struct FCollisionResponseParams;
// struct FCollisionObjectQueryParams; Params = Other; Params = Other;
// Inputs: Each enumerator Any/Static/Dynamic and AllObjects/AllStaticObjects/
// AllDynamicObjects, default-constructed structs, and a named copy source.
// Expected observations: Copied enumerators compare equal. Assigned values
// replace the copy. Default structs are usable. Query and component
// assignment copies TraceTag.
// Boundary/ownership: Assignment copies the parameter object. Enumerators are
// shared constants.

namespace TS_FCollisionQueryParams_ConstructionAndAssignment_01
{
	// EQueryMobilityType Any/Static/Dynamic copy and assign. Oracle: copy equals Any, assign becomes Dynamic, enumerators distinct. Shared constants.
	bool Observe_Surface001_Nominal()
	{
		EQueryMobilityType Any = EQueryMobilityType::Any;
		EQueryMobilityType Static = EQueryMobilityType::Static;
		EQueryMobilityType Dynamic = EQueryMobilityType::Dynamic;
		EQueryMobilityType Copied = Any;
		Copied = Dynamic;
		return Copied == Dynamic && Any != Static && Static != Dynamic && Any == EQueryMobilityType::Any;
	}

	// ECollisionObjectQueryInitType AllObjects/AllStatic/AllDynamic copy and assign. Oracle: copy starts AllObjects, assign becomes AllDynamic, AllObjects != AllStatic. Shared constants.
	bool Observe_Surface005_Nominal()
	{
		ECollisionObjectQueryInitType AllObjects = ECollisionObjectQueryInitType::AllObjects;
		ECollisionObjectQueryInitType AllStaticObjects = ECollisionObjectQueryInitType::AllStaticObjects;
		ECollisionObjectQueryInitType AllDynamicObjects = ECollisionObjectQueryInitType::AllDynamicObjects;
		ECollisionObjectQueryInitType Copied = AllObjects;
		Copied = AllDynamicObjects;
		return Copied == AllDynamicObjects && AllObjects != AllStaticObjects && AllObjects == ECollisionObjectQueryInitType::AllObjects;
	}

	// struct FCollisionQueryParams default construction. Oracle: TraceTag is NAME_None. Value type.
	bool Observe_Surface009_Nominal()
	{
		FCollisionQueryParams Params;
		return Params.TraceTag == NAME_None;
	}

	// struct FCollisionEnabledMask default construction. Oracle: Bits==0. Packed empty mask.
	bool Observe_Surface010_Nominal()
	{
		FCollisionEnabledMask Mask;
		return Mask.Bits == 0;
	}

	// struct FComponentQueryParams default construction. Oracle: TraceTag is NAME_None. Value type.
	bool Observe_Surface011_Nominal()
	{
		FComponentQueryParams Params;
		return Params.TraceTag == NAME_None;
	}

	// struct FCollisionResponseParams default construction vs engine DefaultResponseParam. Oracle: default container WorldStatic is Block. Value type wraps the engine container.
	bool Observe_Surface012_Nominal()
	{
		FCollisionResponseParams Params;
		FCollisionResponseParams EngineDefault = FCollisionResponseParams::DefaultResponseParam;
		FCollisionResponseContainer DefaultContainer = FCollisionResponseContainer::GetDefaultResponseContainer();
		return DefaultContainer.GetResponse(ECollisionChannel::WorldStatic) == ECollisionResponse::ECR_Block;
	}

	// struct FCollisionObjectQueryParams default construction. Oracle: IsValid is false. Empty bitfield.
	bool Observe_Surface013_Nominal()
	{
		FCollisionObjectQueryParams Params;
		return Params.IsValid() == false;
	}

	// FCollisionQueryParams and FComponentQueryParams assignment from a tagged source. Oracle: TraceTag and bTraceComplex copied; source unchanged. Assignment copies the parameter object.
	bool Observe_Assignment_Nominal()
	{
		FCollisionQueryParams Source;
		Source.TraceTag = n"AssignedQuery";
		Source.bTraceComplex = true;
		FCollisionQueryParams Params;
		Params = Source;

		FComponentQueryParams ComponentSource;
		ComponentSource.TraceTag = n"AssignedComponent";
		FComponentQueryParams ComponentParams;
		ComponentParams = ComponentSource;
		return Params.TraceTag == n"AssignedQuery" && Params.bTraceComplex && Source.TraceTag == n"AssignedQuery" && ComponentParams.TraceTag == n"AssignedComponent";
	}
}
/** @end */
