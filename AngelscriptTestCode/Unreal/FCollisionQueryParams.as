/**
 * @version v1
 * @summary FCollisionQueryParams host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FCollisionQueryParams
 *
 * params
 * mask
 * fcollisionenabledmask-bits-assigned-3
 * FCollisionQueryParams-Behavior_02-params
 * fcollisionqueryparams-tracetag-name-none
 * fcollisionqueryparams-ownertag-assigned-n
 * fcollisionqueryparams-btracecomplex-true-then
 * fcollisionqueryparams-bfindinitialoverlaps-true-then
 * fcollisionqueryparams-breturnfaceindex-true-then
 * fcollisionqueryparams-breturnphysicalmaterial-true-then
 * fcollisionqueryparams-bignoreblocks-true-then
 * container-api
 * fcollisionqueryparams-bskipnarrowphase-true-then
 * fcollisionqueryparams-mobilitytype-any-assigned
 * fcollisionqueryparams-ignoremask-0-assigned
 * FCollisionQueryParams-Behavior_03-params
 * fcomponentqueryparams-tracetag-assigned-n
 * fcomponentqueryparams-ownertag-assigned-n
 * fcomponentqueryparams-btracecomplex-true-then
 * fcomponentqueryparams-bfindinitialoverlaps-true-then
 * fcomponentqueryparams-breturnfaceindex-true-then
 * FCollisionQueryParams-Behavior_04-container-api
 * fcomponentqueryparams-bignoreblocks-true-then
 * fcomponentqueryparams-bignoretouches-true-then
 * fcomponentqueryparams-bskipnarrowphase-true-then
 * fcomponentqueryparams-mobilitytype-assigned-static
 * fcomponentqueryparams-ignoremask-assigned-23
 * fcomponentqueryparams-shapecollisionmask-bits-assigned
 * FCollisionQueryParams-Behavior_04-params
 * fcollisionobjectqueryparams-objecttypestoquery-0-assigned
 * FCollisionQueryParams-Behavior_05-container-api
 * do-verify
 * responses
 * replace-channels
 * equerymobilitytype-any-static-dynamic
 * ecollisionobjectqueryinittype-allobjects-allstatic-alldynamic
 * struct-fcollisionqueryparams-construction
 * struct-fcollisionenabledmask-construction
 * struct-fcomponentqueryparams-construction
 * struct-fcollisionresponseparams-construction-vs
 * struct-fcollisionobjectqueryparams-construction
 * assignment
 * to-string
 * clear-ignored-components
 * clear-ignored-actors
 * set-num-ignored-components
 * add-ignored-actor
 * add-ignored-actors
 * add-ignored-component
 * add-ignored-components
 * add-ignored-component-likely-duplicated-root
 * FCollisionQueryParams-MutationAndLifecycle_02-clear-ignored-components
 * FCollisionQueryParams-MutationAndLifecycle_02-clear-ignored-actors
 * FCollisionQueryParams-MutationAndLifecycle_02-set-num-ignored-components
 * FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-actor
 * FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-actors
 * FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-component
 * FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-components
 * FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-component-likely-duplicated-root
 * add-object-types-to-query
 * remove-object-types-to-query
 * set-object-types-to-query
 * set-response
 * set-all-channels
 * create-min-container
 * equerymobilitytype-any-distinct-static
 * equerymobilitytype-static-distinct-dynamic
 * equerymobilitytype-dynamic-distinct-any
 * ecollisionobjectqueryinittype-allobjects-distinct-allstaticobjects
 * ecollisionobjectqueryinittype-allstaticobjects-distinct-alldynamicobjects
 * ecollisionobjectqueryinittype-alldynamicobjects-distinct-allobjects
 * oracle-tostring-non-empty
 * FCollisionQueryParams-NamespaceAndGlobalFunctions_01-oracle-tostring-non-empty
 * surface-028
 * oracle-isvalid-false-bitfield
 * equality
 * get-ignored-components
 * get-ignored-actors
 * get-object-types-to-query
 * get-query-bitfield-64
 * is-valid
 * is-valid-object-query
 * get-collision-channel-from-overlap-filter
 * get-response
 * get-default-response-container
 */
/**
 * @begin params
 * @summary AS-facing API:
 * @topic Unreal
 */
/**
 * @function ObserveParamsNominal
 * @summary AS-facing API:
 * @covers FCollisionQueryParams.params
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

 FCollisionQueryParams Params();
// FCollisionQueryParams Params(const FCollisionQueryParams& Other);
// FCollisionEnabledMask Mask(); FCollisionEnabledMask Mask(ECollisionEnabled CollisionEnabled);
// int8 FCollisionEnabledMask.Bits; FComponentQueryParams Params();
// FComponentQueryParams Params(const FComponentQueryParams& Other);
// FCollisionResponseParams Params(); FCollisionResponseParams Params(ECollisionResponse DefaultResponse);
// FCollisionResponseParams Params(const FCollisionResponseContainer& ResponseContainer);
// Inputs: Default construct, copy of TraceTag n"CopiedQuery", QueryOnly mask,
// ECR_Block response params, and a container with Visibility Block.
// Expected observations: Copy preserves TraceTag. Empty mask Bits is 0.
// QueryOnly mask Bits is nonzero. Response params from ECR_Block and from a
// container are constructible. Visibility on that container is Block.
// Boundary/ownership: Copy construction copies the parameter object. Bits is
// the packed collision-enabled mode mask.
// FCollisionQueryParams/FComponentQueryParams copy plus FCollisionResponseParams from ECR_Block and a Visibility-Block container. Oracle: copied TraceTags and container Visibility is Block. Value copies.
bool ObserveParamsNominal()
{
	FCollisionQueryParams QueryParams;
	QueryParams.TraceTag = n"CopiedQuery";
	FCollisionQueryParams QueryCopy(QueryParams);

	FComponentQueryParams ComponentParams;
	ComponentParams.TraceTag = n"CopiedComponent";
	FComponentQueryParams ComponentCopy(ComponentParams);

	FCollisionResponseParams DefaultResponseParams;
	FCollisionResponseParams BlockResponseParams(ECollisionResponse::ECR_Block);
	FCollisionResponseContainer Container(ECollisionResponse::ECR_Ignore);
	Container.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	FCollisionResponseParams ContainerResponseParams(Container);
	FCollisionResponseParams EngineDefault = FCollisionResponseParams::DefaultResponseParam;
	return QueryCopy.TraceTag == n"CopiedQuery" && ComponentCopy.TraceTag == n"CopiedComponent" && Container.GetResponse(ECollisionChannel::Visibility) == ECollisionResponse::ECR_Block;
}
/** @end */
/**
 * @begin mask
 * @summary FCollisionEnabledMask() vs QueryOnly vs QueryAndPhysics.
 * @topic Unreal
 */
/**
 * @function ObserveMaskNominal
 * @summary FCollisionEnabledMask() vs QueryOnly vs QueryAndPhysics.
 * @covers FCollisionQueryParams.mask
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveMaskNominal()
{
	FCollisionEnabledMask EmptyMask;
	FCollisionEnabledMask QueryOnlyMask(ECollisionEnabled::QueryOnly);
	FCollisionEnabledMask PhysicsMask(ECollisionEnabled::QueryAndPhysics);
	return EmptyMask.Bits == 0 && QueryOnlyMask.Bits != 0 && PhysicsMask.Bits != 0 && PhysicsMask.Bits != QueryOnlyMask.Bits;
}
/** @end */
/**
 * @begin fcollisionenabledmask-bits-assigned-3
 * @summary FCollisionEnabledMask.Bits default, assigned 3, and QueryOnly.
 * @topic Unreal
 */
/**
 * @function ObserveSurface020Nominal
 * @summary FCollisionEnabledMask.Bits default, assigned 3, and QueryOnly.
 * @covers FCollisionQueryParams.fcollisionenabledmask-bits-assigned-3
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface020Nominal()
{
	FCollisionEnabledMask Mask;
	int8 EmptyBits = Mask.Bits;
	Mask.Bits = 3;
	int8 Assigned = Mask.Bits;
	FCollisionEnabledMask QueryOnlyMask(ECollisionEnabled::QueryOnly);
	int8 QueryOnlyBits = QueryOnlyMask.Bits;
	return EmptyBits == 0 && Assigned == 3 && QueryOnlyBits != 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-Behavior_02-params
 * @summary AS-facing API:
 * @topic Unreal
 */
/**
 * @function ObserveParamsNominal
 * @summary AS-facing API:
 * @covers FCollisionQueryParams.params
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

 FCollisionObjectQueryParams Params();
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
// FCollisionObjectQueryParams empty vs WorldStatic, plus tagged FCollisionQueryParams(n"ConstructorQuery", true, IgnoreActor). Oracle: empty invalid, WorldStatic valid, tag stored, ignore Num==1, simple not complex. Runner owns IgnoreActor.
bool ObserveParamsNominal(AActor IgnoreActor)
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
/** @end */
/**
 * @begin fcollisionqueryparams-tracetag-name-none
 * @summary FCollisionQueryParams.TraceTag default NAME_None, assigned n"TraceTag", then NAME_None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface033Nominal
 * @summary FCollisionQueryParams.TraceTag default NAME_None, assigned n"TraceTag", then NAME_None.
 * @covers FCollisionQueryParams.fcollisionqueryparams-tracetag-name-none
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface033Nominal()
{
	FCollisionQueryParams Params;
	Params.TraceTag = n"TraceTag";
	FName Assigned = Params.TraceTag;
	Params.TraceTag = NAME_None;
	return Assigned == n"TraceTag" && Params.TraceTag == NAME_None;
}
/** @end */
/**
 * @begin fcollisionqueryparams-ownertag-assigned-n
 * @summary FCollisionQueryParams.OwnerTag assigned n"OwnerTag" then NAME_None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface034Nominal
 * @summary FCollisionQueryParams.OwnerTag assigned n"OwnerTag" then NAME_None.
 * @covers FCollisionQueryParams.fcollisionqueryparams-ownertag-assigned-n
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface034Nominal()
{
	FCollisionQueryParams Params;
	Params.OwnerTag = n"OwnerTag";
	FName Assigned = Params.OwnerTag;
	Params.OwnerTag = NAME_None;
	return Assigned == n"OwnerTag" && Params.OwnerTag == NAME_None;
}
/** @end */
/**
 * @begin fcollisionqueryparams-btracecomplex-true-then
 * @summary FCollisionQueryParams.bTraceComplex true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface035Nominal
 * @summary FCollisionQueryParams.bTraceComplex true then false.
 * @covers FCollisionQueryParams.fcollisionqueryparams-btracecomplex-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface035Nominal()
{
	FCollisionQueryParams Params;
	Params.bTraceComplex = true;
	bool bSetTrue = Params.bTraceComplex;
	Params.bTraceComplex = false;
	bool bSetFalse = Params.bTraceComplex;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcollisionqueryparams-bfindinitialoverlaps-true-then
 * @summary FCollisionQueryParams.bFindInitialOverlaps true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface036Nominal
 * @summary FCollisionQueryParams.bFindInitialOverlaps true then false.
 * @covers FCollisionQueryParams.fcollisionqueryparams-bfindinitialoverlaps-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface036Nominal()
{
	FCollisionQueryParams Params;
	Params.bFindInitialOverlaps = true;
	bool bSetTrue = Params.bFindInitialOverlaps;
	Params.bFindInitialOverlaps = false;
	bool bSetFalse = Params.bFindInitialOverlaps;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcollisionqueryparams-breturnfaceindex-true-then
 * @summary FCollisionQueryParams.bReturnFaceIndex true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface037Nominal
 * @summary FCollisionQueryParams.bReturnFaceIndex true then false.
 * @covers FCollisionQueryParams.fcollisionqueryparams-breturnfaceindex-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface037Nominal()
{
	FCollisionQueryParams Params;
	Params.bReturnFaceIndex = true;
	bool bSetTrue = Params.bReturnFaceIndex;
	Params.bReturnFaceIndex = false;
	bool bSetFalse = Params.bReturnFaceIndex;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcollisionqueryparams-breturnphysicalmaterial-true-then
 * @summary FCollisionQueryParams.bReturnPhysicalMaterial true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface038Nominal
 * @summary FCollisionQueryParams.bReturnPhysicalMaterial true then false.
 * @covers FCollisionQueryParams.fcollisionqueryparams-breturnphysicalmaterial-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface038Nominal()
{
	FCollisionQueryParams Params;
	Params.bReturnPhysicalMaterial = true;
	bool bSetTrue = Params.bReturnPhysicalMaterial;
	Params.bReturnPhysicalMaterial = false;
	bool bSetFalse = Params.bReturnPhysicalMaterial;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcollisionqueryparams-bignoreblocks-true-then
 * @summary FCollisionQueryParams.bIgnoreBlocks true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface039Nominal
 * @summary FCollisionQueryParams.bIgnoreBlocks true then false.
 * @covers FCollisionQueryParams.fcollisionqueryparams-bignoreblocks-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveSurface039Nominal()
{
	FCollisionQueryParams Params;
	Params.bIgnoreBlocks = true;
	bool bSetTrue = Params.bIgnoreBlocks;
	Params.bIgnoreBlocks = false;
	bool bSetFalse = Params.bIgnoreBlocks;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface040Nominal
 * @summary Observe the container API.
 * @covers FCollisionQueryParams.container-api
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FComponentQueryParams Params(FName InTraceTag, const AActor InIgnoreActor, FCollisionEnabledMask CollisionEnabledMask);
// FName FComponentQueryParams.TraceTag; FName FComponentQueryParams.OwnerTag;
// bool FComponentQueryParams.bTraceComplex; bool FComponentQueryParams.bFindInitialOverlaps;
// bool FComponentQueryParams.bReturnFaceIndex;
// Inputs: true/false flags, EQueryMobilityType::Dynamic, IgnoreMask 17,
// n"ConstructorComponent", runner-owned IgnoreActor, QueryOnly mask.
// Expected observations: Flag fields round-trip. MobilityType stores Dynamic.
// Tagged component constructor stores TraceTag and ShapeCollisionMask.Bits.
// Boundary/ownership: CollisionEnabledMask restricts allowed collision modes.
// Null InIgnoreActor is skipped. SetupOwner=Runner. CleanupOwner=Runner.
// FCollisionQueryParams.bIgnoreTouches true then false. Oracle: true then false. Flag field round-trip.
bool ObserveSurface040Nominal()
{
	FCollisionQueryParams Params;
	Params.bIgnoreTouches = true;
	bool bSetTrue = Params.bIgnoreTouches;
	Params.bIgnoreTouches = false;
	bool bSetFalse = Params.bIgnoreTouches;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcollisionqueryparams-bskipnarrowphase-true-then
 * @summary FCollisionQueryParams.bSkipNarrowPhase true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface041Nominal
 * @summary FCollisionQueryParams.bSkipNarrowPhase true then false.
 * @covers FCollisionQueryParams.fcollisionqueryparams-bskipnarrowphase-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface041Nominal()
{
	FCollisionQueryParams Params;
	Params.bSkipNarrowPhase = true;
	bool bSetTrue = Params.bSkipNarrowPhase;
	Params.bSkipNarrowPhase = false;
	bool bSetFalse = Params.bSkipNarrowPhase;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcollisionqueryparams-mobilitytype-any-assigned
 * @summary FCollisionQueryParams.MobilityType default Any, assigned Dynamic, then Static.
 * @topic Unreal
 */
/**
 * @function ObserveSurface042Nominal
 * @summary FCollisionQueryParams.MobilityType default Any, assigned Dynamic, then Static.
 * @covers FCollisionQueryParams.fcollisionqueryparams-mobilitytype-any-assigned
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface042Nominal()
{
	FCollisionQueryParams Params;
	EQueryMobilityType DefaultType = Params.MobilityType;
	Params.MobilityType = EQueryMobilityType::Dynamic;
	EQueryMobilityType Assigned = Params.MobilityType;
	Params.MobilityType = EQueryMobilityType::Static;
	return Assigned == EQueryMobilityType::Dynamic && Params.MobilityType == EQueryMobilityType::Static && DefaultType == EQueryMobilityType::Any;
}
/** @end */
/**
 * @begin fcollisionqueryparams-ignoremask-0-assigned
 * @summary FCollisionQueryParams.IgnoreMask default 0, assigned 17, then 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface043Nominal
 * @summary FCollisionQueryParams.IgnoreMask default 0, assigned 17, then 0.
 * @covers FCollisionQueryParams.fcollisionqueryparams-ignoremask-0-assigned
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface043Nominal()
{
	FCollisionQueryParams Params;
	uint8 DefaultMask = Params.IgnoreMask;
	Params.IgnoreMask = 17;
	uint8 Assigned = Params.IgnoreMask;
	Params.IgnoreMask = 0;
	return DefaultMask == 0 && Assigned == 17 && Params.IgnoreMask == 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-Behavior_03-params
 * @summary FComponentQueryParams(n"ConstructorComponent", IgnoreActor, QueryOnly).
 * @topic Unreal
 */
/**
 * @function ObserveParamsNominal
 * @summary FComponentQueryParams(n"ConstructorComponent", IgnoreActor, QueryOnly).
 * @covers FCollisionQueryParams.params
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveParamsNominal(AActor IgnoreActor)
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
/** @end */
/**
 * @begin fcomponentqueryparams-tracetag-assigned-n
 * @summary FComponentQueryParams.TraceTag assigned n"ComponentTrace" then NAME_None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface058Nominal
 * @summary FComponentQueryParams.TraceTag assigned n"ComponentTrace" then NAME_None.
 * @covers FCollisionQueryParams.fcomponentqueryparams-tracetag-assigned-n
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface058Nominal()
{
	FComponentQueryParams Params;
	Params.TraceTag = n"ComponentTrace";
	FName Assigned = Params.TraceTag;
	Params.TraceTag = NAME_None;
	return Assigned == n"ComponentTrace" && Params.TraceTag == NAME_None;
}
/** @end */
/**
 * @begin fcomponentqueryparams-ownertag-assigned-n
 * @summary FComponentQueryParams.OwnerTag assigned n"ComponentOwner" then NAME_None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface059Nominal
 * @summary FComponentQueryParams.OwnerTag assigned n"ComponentOwner" then NAME_None.
 * @covers FCollisionQueryParams.fcomponentqueryparams-ownertag-assigned-n
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface059Nominal()
{
	FComponentQueryParams Params;
	Params.OwnerTag = n"ComponentOwner";
	FName Assigned = Params.OwnerTag;
	Params.OwnerTag = NAME_None;
	return Assigned == n"ComponentOwner" && Params.OwnerTag == NAME_None;
}
/** @end */
/**
 * @begin fcomponentqueryparams-btracecomplex-true-then
 * @summary FComponentQueryParams.bTraceComplex true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface060Nominal
 * @summary FComponentQueryParams.bTraceComplex true then false.
 * @covers FCollisionQueryParams.fcomponentqueryparams-btracecomplex-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface060Nominal()
{
	FComponentQueryParams Params;
	Params.bTraceComplex = true;
	bool bSetTrue = Params.bTraceComplex;
	Params.bTraceComplex = false;
	bool bSetFalse = Params.bTraceComplex;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcomponentqueryparams-bfindinitialoverlaps-true-then
 * @summary FComponentQueryParams.bFindInitialOverlaps true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface061Nominal
 * @summary FComponentQueryParams.bFindInitialOverlaps true then false.
 * @covers FCollisionQueryParams.fcomponentqueryparams-bfindinitialoverlaps-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface061Nominal()
{
	FComponentQueryParams Params;
	Params.bFindInitialOverlaps = true;
	bool bSetTrue = Params.bFindInitialOverlaps;
	Params.bFindInitialOverlaps = false;
	bool bSetFalse = Params.bFindInitialOverlaps;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcomponentqueryparams-breturnfaceindex-true-then
 * @summary FComponentQueryParams.bReturnFaceIndex true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface062Nominal
 * @summary FComponentQueryParams.bReturnFaceIndex true then false.
 * @covers FCollisionQueryParams.fcomponentqueryparams-breturnfaceindex-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface062Nominal()
{
	FComponentQueryParams Params;
	Params.bReturnFaceIndex = true;
	bool bSetTrue = Params.bReturnFaceIndex;
	Params.bReturnFaceIndex = false;
	bool bSetFalse = Params.bReturnFaceIndex;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin FCollisionQueryParams-Behavior_04-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface063Nominal
 * @summary Observe the container API.
 * @covers FCollisionQueryParams.container-api
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FCollisionObjectQueryParams Params(ECollisionObjectQueryInitType QueryType);
// FCollisionObjectQueryParams Params(int32 InObjectTypesToQuery);
// int32 FCollisionObjectQueryParams.ObjectTypesToQuery;
// Inputs: true/false flags, Static mobility, IgnoreMask 23, ShapeCollisionMask
// Bits 3, AllObjects/AllStaticObjects/AllDynamicObjects, packed bits 1.
// Expected observations: Flag fields round-trip. Init-type constructors are
// valid. Packed bits 1 is valid and ObjectTypesToQuery is 1.
// Boundary/ownership: ShapeCollisionMask restricts collision-enabled state.
// ObjectTypesToQuery exposes the packed low object-channel bits.
// FComponentQueryParams.bReturnPhysicalMaterial true then false. Oracle: true then false. Flag field round-trip.
bool ObserveSurface063Nominal()
{
	FComponentQueryParams Params;
	Params.bReturnPhysicalMaterial = true;
	bool bSetTrue = Params.bReturnPhysicalMaterial;
	Params.bReturnPhysicalMaterial = false;
	bool bSetFalse = Params.bReturnPhysicalMaterial;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcomponentqueryparams-bignoreblocks-true-then
 * @summary FComponentQueryParams.bIgnoreBlocks true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface064Nominal
 * @summary FComponentQueryParams.bIgnoreBlocks true then false.
 * @covers FCollisionQueryParams.fcomponentqueryparams-bignoreblocks-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface064Nominal()
{
	FComponentQueryParams Params;
	Params.bIgnoreBlocks = true;
	bool bSetTrue = Params.bIgnoreBlocks;
	Params.bIgnoreBlocks = false;
	bool bSetFalse = Params.bIgnoreBlocks;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcomponentqueryparams-bignoretouches-true-then
 * @summary FComponentQueryParams.bIgnoreTouches true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface065Nominal
 * @summary FComponentQueryParams.bIgnoreTouches true then false.
 * @covers FCollisionQueryParams.fcomponentqueryparams-bignoretouches-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface065Nominal()
{
	FComponentQueryParams Params;
	Params.bIgnoreTouches = true;
	bool bSetTrue = Params.bIgnoreTouches;
	Params.bIgnoreTouches = false;
	bool bSetFalse = Params.bIgnoreTouches;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcomponentqueryparams-bskipnarrowphase-true-then
 * @summary FComponentQueryParams.bSkipNarrowPhase true then false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface066Nominal
 * @summary FComponentQueryParams.bSkipNarrowPhase true then false.
 * @covers FCollisionQueryParams.fcomponentqueryparams-bskipnarrowphase-true-then
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface066Nominal()
{
	FComponentQueryParams Params;
	Params.bSkipNarrowPhase = true;
	bool bSetTrue = Params.bSkipNarrowPhase;
	Params.bSkipNarrowPhase = false;
	bool bSetFalse = Params.bSkipNarrowPhase;
	return bSetTrue && !bSetFalse;
}
/** @end */
/**
 * @begin fcomponentqueryparams-mobilitytype-assigned-static
 * @summary FComponentQueryParams.MobilityType assigned Static then Any.
 * @topic Unreal
 */
/**
 * @function ObserveSurface067Nominal
 * @summary FComponentQueryParams.MobilityType assigned Static then Any.
 * @covers FCollisionQueryParams.fcomponentqueryparams-mobilitytype-assigned-static
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface067Nominal()
{
	FComponentQueryParams Params;
	Params.MobilityType = EQueryMobilityType::Static;
	EQueryMobilityType Assigned = Params.MobilityType;
	Params.MobilityType = EQueryMobilityType::Any;
	return Assigned == EQueryMobilityType::Static && Params.MobilityType == EQueryMobilityType::Any;
}
/** @end */
/**
 * @begin fcomponentqueryparams-ignoremask-assigned-23
 * @summary FComponentQueryParams.IgnoreMask assigned 23 then 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface068Nominal
 * @summary FComponentQueryParams.IgnoreMask assigned 23 then 0.
 * @covers FCollisionQueryParams.fcomponentqueryparams-ignoremask-assigned-23
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface068Nominal()
{
	FComponentQueryParams Params;
	Params.IgnoreMask = 23;
	uint8 Assigned = Params.IgnoreMask;
	Params.IgnoreMask = 0;
	return Assigned == 23 && Params.IgnoreMask == 0;
}
/** @end */
/**
 * @begin fcomponentqueryparams-shapecollisionmask-bits-assigned
 * @summary FComponentQueryParams.ShapeCollisionMask.Bits assigned 3.
 * @topic Unreal
 */
/**
 * @function ObserveSurface069Nominal
 * @summary FComponentQueryParams.ShapeCollisionMask.Bits assigned 3.
 * @covers FCollisionQueryParams.fcomponentqueryparams-shapecollisionmask-bits-assigned
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface069Nominal()
{
	FComponentQueryParams Params;
	FCollisionEnabledMask Mask = Params.ShapeCollisionMask;
	Mask.Bits = 3;
	Params.ShapeCollisionMask = Mask;
	int8 Assigned = Params.ShapeCollisionMask.Bits;
	return Assigned == 3;
}
/** @end */
/**
 * @begin FCollisionQueryParams-Behavior_04-params
 * @summary FCollisionObjectQueryParams AllObjects/AllStatic/AllDynamic and packed bits 1.
 * @topic Unreal
 */
/**
 * @function ObserveParamsNominal
 * @summary FCollisionObjectQueryParams AllObjects/AllStatic/AllDynamic and packed bits 1.
 * @covers FCollisionQueryParams.params
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveParamsNominal()
{
	FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
	FCollisionObjectQueryParams AllStaticObjects(ECollisionObjectQueryInitType::AllStaticObjects);
	FCollisionObjectQueryParams AllDynamicObjects(ECollisionObjectQueryInitType::AllDynamicObjects);
	FCollisionObjectQueryParams Bitfield(1);
	return AllObjects.IsValid() && AllStaticObjects.IsValid() && AllDynamicObjects.IsValid() && Bitfield.IsValid() && Bitfield.ObjectTypesToQuery == 1;
}
/** @end */
/**
 * @begin fcollisionobjectqueryparams-objecttypestoquery-0-assigned
 * @summary FCollisionObjectQueryParams.ObjectTypesToQuery default 0, assigned 1, then 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface085Nominal
 * @summary FCollisionObjectQueryParams.ObjectTypesToQuery default 0, assigned 1, then 0.
 * @covers FCollisionQueryParams.fcollisionobjectqueryparams-objecttypestoquery-0-assigned
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface085Nominal()
{
	FCollisionObjectQueryParams Params;
	int32 DefaultBits = Params.ObjectTypesToQuery;
	Params.ObjectTypesToQuery = 1;
	int32 Assigned = Params.ObjectTypesToQuery;
	Params.ObjectTypesToQuery = 0;
	return DefaultBits == 0 && Assigned == 1 && Params.ObjectTypesToQuery == 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-Behavior_05-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface086Nominal
 * @summary Observe the container API.
 * @covers FCollisionQueryParams.container-api
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FCollisionResponseContainer Responses(ECollisionResponse DefaultResponse);
// bool FCollisionResponseContainer.ReplaceChannels(ECollisionResponse OldResponse, ECollisionResponse NewResponse);
// Inputs: IgnoreMask 29, a valid WorldStatic object query, ECR_Ignore
// container, replace Ignore with Block, then Block with Overlap, then a
// no-op replace of a missing OldResponse.
// Expected observations: IgnoreMask round-trips. DoVerify returns on a valid
// bitfield. Constructed Ignore container GetResponse is Ignore. ReplaceChannels
// returns true when any channel changes and false when none match.
// Boundary/ownership: DoVerify is an engine debug check. ReplaceChannels
// mutates matching channels only.
// FCollisionObjectQueryParams.IgnoreMask default 0, assigned 29, then 0. Oracle: 0 then 29 then 0. Packed extra filter bits.
bool ObserveSurface086Nominal()
{
	FCollisionObjectQueryParams Params;
	uint8 DefaultMask = Params.IgnoreMask;
	Params.IgnoreMask = 29;
	uint8 Assigned = Params.IgnoreMask;
	Params.IgnoreMask = 0;
	return DefaultMask == 0 && Assigned == 29 && Params.IgnoreMask == 0;
}
/** @end */
/**
 * @begin do-verify
 * @summary FCollisionObjectQueryParams.DoVerify on empty, WorldStatic, and AllObjects.
 * @topic Unreal
 */
/**
 * @function ObserveDoVerifyNominal
 * @summary FCollisionObjectQueryParams.DoVerify on empty, WorldStatic, and AllObjects.
 * @covers FCollisionQueryParams.do-verify
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDoVerifyNominal()
{
	FCollisionObjectQueryParams Empty;
	Empty.DoVerify();
	FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
	WorldStatic.DoVerify();
	FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
	AllObjects.DoVerify();
	return !Empty.IsValid() && WorldStatic.IsValid() && AllObjects.IsValid();
}
/** @end */
/**
 * @begin responses
 * @summary FCollisionResponseContainer(ECR_Ignore/Block/Overlap).
 * @topic Unreal
 */
/**
 * @function ObserveResponsesNominal
 * @summary FCollisionResponseContainer(ECR_Ignore/Block/Overlap).
 * @covers FCollisionQueryParams.responses
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveResponsesNominal()
{
	FCollisionResponseContainer IgnoreAll(ECollisionResponse::ECR_Ignore);
	ECollisionResponse Visibility = IgnoreAll.GetResponse(ECollisionChannel::Visibility);
	FCollisionResponseContainer BlockAll(ECollisionResponse::ECR_Block);
	ECollisionResponse WorldStatic = BlockAll.GetResponse(ECollisionChannel::WorldStatic);
	FCollisionResponseContainer OverlapAll(ECollisionResponse::ECR_Overlap);
	ECollisionResponse Camera = OverlapAll.GetResponse(ECollisionChannel::Camera);
	return Visibility == ECollisionResponse::ECR_Ignore && WorldStatic == ECollisionResponse::ECR_Block && Camera == ECollisionResponse::ECR_Overlap;
}
/** @end */
/**
 * @begin replace-channels
 * @summary ReplaceChannels Ignore->Block then Block->Overlap then missing Block.
 * @topic Unreal
 */
/**
 * @function ObserveReplaceChannelsNominal
 * @summary ReplaceChannels Ignore->Block then Block->Overlap then missing Block.
 * @covers FCollisionQueryParams.replace-channels
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveReplaceChannelsNominal()
{
	FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
	bool bReplacedIgnore = Responses.ReplaceChannels(ECollisionResponse::ECR_Ignore, ECollisionResponse::ECR_Block);
	ECollisionResponse AfterBlock = Responses.GetResponse(ECollisionChannel::Visibility);
	bool bReplacedBlock = Responses.ReplaceChannels(ECollisionResponse::ECR_Block, ECollisionResponse::ECR_Overlap);
	ECollisionResponse AfterOverlap = Responses.GetResponse(ECollisionChannel::WorldStatic);
	bool bMissingOld = Responses.ReplaceChannels(ECollisionResponse::ECR_Block, ECollisionResponse::ECR_Ignore);
	return bReplacedIgnore && AfterBlock == ECollisionResponse::ECR_Block && bReplacedBlock && AfterOverlap == ECollisionResponse::ECR_Overlap && !bMissingOld;
}
/** @end */
/**
 * @begin equerymobilitytype-any-static-dynamic
 * @summary EQueryMobilityType Any/Static/Dynamic copy and assign.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary EQueryMobilityType Any/Static/Dynamic copy and assign.
 * @covers FCollisionQueryParams.equerymobilitytype-any-static-dynamic
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	EQueryMobilityType Any = EQueryMobilityType::Any;
	EQueryMobilityType Static = EQueryMobilityType::Static;
	EQueryMobilityType Dynamic = EQueryMobilityType::Dynamic;
	EQueryMobilityType Copied = Any;
	Copied = Dynamic;
	return Copied == Dynamic && Any != Static && Static != Dynamic && Any == EQueryMobilityType::Any;
}
/** @end */
/**
 * @begin ecollisionobjectqueryinittype-allobjects-allstatic-alldynamic
 * @summary ECollisionObjectQueryInitType AllObjects/AllStatic/AllDynamic copy and assign.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary ECollisionObjectQueryInitType AllObjects/AllStatic/AllDynamic copy and assign.
 * @covers FCollisionQueryParams.ecollisionobjectqueryinittype-allobjects-allstatic-alldynamic
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
{
	ECollisionObjectQueryInitType AllObjects = ECollisionObjectQueryInitType::AllObjects;
	ECollisionObjectQueryInitType AllStaticObjects = ECollisionObjectQueryInitType::AllStaticObjects;
	ECollisionObjectQueryInitType AllDynamicObjects = ECollisionObjectQueryInitType::AllDynamicObjects;
	ECollisionObjectQueryInitType Copied = AllObjects;
	Copied = AllDynamicObjects;
	return Copied == AllDynamicObjects && AllObjects != AllStaticObjects && AllObjects == ECollisionObjectQueryInitType::AllObjects;
}
/** @end */
/**
 * @begin struct-fcollisionqueryparams-construction
 * @summary struct FCollisionQueryParams default construction.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary struct FCollisionQueryParams default construction.
 * @covers FCollisionQueryParams.struct-fcollisionqueryparams-construction
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface009Nominal()
{
	FCollisionQueryParams Params;
	return Params.TraceTag == NAME_None;
}
/** @end */
/**
 * @begin struct-fcollisionenabledmask-construction
 * @summary struct FCollisionEnabledMask default construction.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary struct FCollisionEnabledMask default construction.
 * @covers FCollisionQueryParams.struct-fcollisionenabledmask-construction
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface010Nominal()
{
	FCollisionEnabledMask Mask;
	return Mask.Bits == 0;
}
/** @end */
/**
 * @begin struct-fcomponentqueryparams-construction
 * @summary struct FComponentQueryParams default construction.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary struct FComponentQueryParams default construction.
 * @covers FCollisionQueryParams.struct-fcomponentqueryparams-construction
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface011Nominal()
{
	FComponentQueryParams Params;
	return Params.TraceTag == NAME_None;
}
/** @end */
/**
 * @begin struct-fcollisionresponseparams-construction-vs
 * @summary struct FCollisionResponseParams default construction vs engine DefaultResponseParam.
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary struct FCollisionResponseParams default construction vs engine DefaultResponseParam.
 * @covers FCollisionQueryParams.struct-fcollisionresponseparams-construction-vs
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface012Nominal()
{
	FCollisionResponseParams Params;
	FCollisionResponseParams EngineDefault = FCollisionResponseParams::DefaultResponseParam;
	FCollisionResponseContainer DefaultContainer = FCollisionResponseContainer::GetDefaultResponseContainer();
	return DefaultContainer.GetResponse(ECollisionChannel::WorldStatic) == ECollisionResponse::ECR_Block;
}
/** @end */
/**
 * @begin struct-fcollisionobjectqueryparams-construction
 * @summary struct FCollisionObjectQueryParams default construction.
 * @topic Unreal
 */
/**
 * @function ObserveSurface013Nominal
 * @summary struct FCollisionObjectQueryParams default construction.
 * @covers FCollisionQueryParams.struct-fcollisionobjectqueryparams-construction
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface013Nominal()
{
	FCollisionObjectQueryParams Params;
	return Params.IsValid() == false;
}
/** @end */
/**
 * @begin assignment
 * @summary FCollisionQueryParams and FComponentQueryParams assignment from a tagged source.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary FCollisionQueryParams and FComponentQueryParams assignment from a tagged source.
 * @covers FCollisionQueryParams.assignment
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
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
/** @end */
/**
 * @begin to-string
 * @summary parameter object.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary parameter object.
 * @covers FCollisionQueryParams.to-string
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FCollisionQueryParams QueryParams;
	FString DefaultQuery = QueryParams.ToString();
	QueryParams.TraceTag = n"QueryTag";
	QueryParams.bTraceComplex = true;
	FString NamedQuery = QueryParams.ToString();

	FComponentQueryParams ComponentParams;
	FString DefaultComponent = ComponentParams.ToString();
	ComponentParams.TraceTag = n"ComponentTag";
	FString NamedComponent = ComponentParams.ToString();
	return NamedQuery.Len() > 0 && NamedComponent.Len() > 0;
}
/** @end */
/**
 * @begin clear-ignored-components
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveClearIgnoredComponentsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.clear-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreComponent is null");
	}
	FCollisionQueryParams Params;
	Params.AddIgnoredComponent(IgnoreComponent);
	Params.ClearIgnoredComponents();
	TArray<uint32> After = Params.GetIgnoredComponents();
	return After.Num() == 0;
}
/** @end */
/**
 * @begin clear-ignored-actors
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveClearIgnoredActorsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.clear-ignored-actors
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearIgnoredActorsNominal(AActor IgnoreActor)
{
	if (IgnoreActor is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreActor is null");
	}
	FCollisionQueryParams Params;
	Params.AddIgnoredActor(IgnoreActor);
	Params.ClearIgnoredActors();
	TArray<uint32> After = Params.GetIgnoredActors();
	return After.Num() == 0;
}
/** @end */
/**
 * @begin set-num-ignored-components
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveSetNumIgnoredComponentsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.set-num-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetNumIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreComponent is null");
	}
	FCollisionQueryParams Params;
	Params.AddIgnoredComponent(IgnoreComponent);
	Params.SetNumIgnoredComponents(1);
	int32 One = Params.GetIgnoredComponents().Num();
	Params.SetNumIgnoredComponents(0);
	int32 Zero = Params.GetIgnoredComponents().Num();
	return One == 1 && Zero == 0;
}
/** @end */
/**
 * @begin add-ignored-actor
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredActorNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-actor
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredActorNominal(AActor IgnoreActor)
{
	if (IgnoreActor is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreActor is null");
	}
	FCollisionQueryParams Params;
	AActor NullActor;
	Params.AddIgnoredActor(NullActor);
	int32 AfterNull = Params.GetIgnoredActors().Num();
	Params.AddIgnoredActor(IgnoreActor);
	int32 AfterActor = Params.GetIgnoredActors().Num();
	uint32 ActorId = 42;
	Params.AddIgnoredActor(ActorId);
	TArray<uint32> Ids = Params.GetIgnoredActors();
	bool bIdStored = false;
	for (int32 Index = 0; Index < Ids.Num(); ++Index)
	{
		if (Ids[Index] == 42)
		{
			bIdStored = true;
		}
	}
	return AfterNull == 0 && AfterActor == 1 && bIdStored;
}
/** @end */
/**
 * @begin add-ignored-actors
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredActorsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-actors
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredActorsNominal(AActor IgnoreActor)
{
	if (IgnoreActor is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreActor is null");
	}
	FCollisionQueryParams Params;
	TArray<AActor> Actors;
	Actors.Add(IgnoreActor);
	AActor NullActor;
	Actors.Add(NullActor);
	Params.AddIgnoredActors(Actors);
	int32 AfterActors = Params.GetIgnoredActors().Num();

	TArray<const AActor> ConstActors;
	ConstActors.Add(IgnoreActor);
	Params.AddIgnoredActors(ConstActors);
	int32 AfterConst = Params.GetIgnoredActors().Num();
	return AfterActors >= 1 && AfterConst >= AfterActors;
}
/** @end */
/**
 * @begin add-ignored-component
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredComponentNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-component
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredComponentNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreComponent is null");
	}
	FCollisionQueryParams Params;
	UPrimitiveComponent NullComponent;
	Params.AddIgnoredComponent(NullComponent);
	int32 AfterNull = Params.GetIgnoredComponents().Num();
	Params.AddIgnoredComponent(IgnoreComponent);
	int32 AfterComponent = Params.GetIgnoredComponents().Num();
	return AfterNull == 0 && AfterComponent == 1;
}
/** @end */
/**
 * @begin add-ignored-components
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredComponentsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreComponent is null");
	}
	FCollisionQueryParams Params;
	TArray<UPrimitiveComponent> Components;
	Components.Add(IgnoreComponent);
	UPrimitiveComponent NullComponent;
	Components.Add(NullComponent);
	Params.AddIgnoredComponents(Components);
	int32 After = Params.GetIgnoredComponents().Num();
	return After == 1;
}
/** @end */
/**
 * @begin add-ignored-component-likely-duplicated-root
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredComponentLikelyDuplicatedRootNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-component-likely-duplicated-root
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredComponentLikelyDuplicatedRootNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_01 setup: required IgnoreComponent is null");
	}
	FCollisionQueryParams Params;
	UPrimitiveComponent NullComponent;
	Params.AddIgnoredComponent_LikelyDuplicatedRoot(NullComponent);
	int32 AfterNull = Params.GetIgnoredComponents().Num();
	Params.AddIgnoredComponent_LikelyDuplicatedRoot(IgnoreComponent);
	int32 AfterRoot = Params.GetIgnoredComponents().Num();
	Params.AddIgnoredComponent_LikelyDuplicatedRoot(IgnoreComponent);
	int32 AfterDuplicate = Params.GetIgnoredComponents().Num();
	return AfterNull == 0 && AfterRoot >= 1 && AfterDuplicate >= AfterRoot;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-clear-ignored-components
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveClearIgnoredComponentsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.clear-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
	}
	FComponentQueryParams Params;
	Params.AddIgnoredComponent(IgnoreComponent);
	Params.ClearIgnoredComponents();
	TArray<uint32> After = Params.GetIgnoredComponents();
	return After.Num() == 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-clear-ignored-actors
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveClearIgnoredActorsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.clear-ignored-actors
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearIgnoredActorsNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required Actor is null");
	}
	FComponentQueryParams Params;
	Params.AddIgnoredActor(Actor);
	Params.ClearIgnoredActors();
	TArray<uint32> After = Params.GetIgnoredActors();
	return After.Num() == 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-set-num-ignored-components
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveSetNumIgnoredComponentsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.set-num-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetNumIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
	}
	FComponentQueryParams Params;
	Params.AddIgnoredComponent(IgnoreComponent);
	Params.SetNumIgnoredComponents(1);
	int32 One = Params.GetIgnoredComponents().Num();
	Params.SetNumIgnoredComponents(0);
	int32 Zero = Params.GetIgnoredComponents().Num();
	return One == 1 && Zero == 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-actor
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredActorNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-actor
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredActorNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required Actor is null");
	}
	FComponentQueryParams Params;
	AActor NullActor;
	Params.AddIgnoredActor(NullActor);
	int32 AfterNull = Params.GetIgnoredActors().Num();
	Params.AddIgnoredActor(Actor);
	int32 AfterActor = Params.GetIgnoredActors().Num();
	uint32 ActorId = 42;
	Params.AddIgnoredActor(ActorId);
	TArray<uint32> Ids = Params.GetIgnoredActors();
	bool bIdStored = false;
	for (int32 Index = 0; Index < Ids.Num(); ++Index)
	{
		if (Ids[Index] == 42)
		{
			bIdStored = true;
		}
	}
	return AfterNull == 0 && AfterActor == 1 && bIdStored;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-actors
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredActorsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-actors
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredActorsNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required Actor is null");
	}
	FComponentQueryParams Params;
	TArray<AActor> Actors;
	Actors.Add(Actor);
	AActor NullActor;
	Actors.Add(NullActor);
	Params.AddIgnoredActors(Actors);
	int32 AfterActors = Params.GetIgnoredActors().Num();

	TArray<const AActor> ConstActors;
	ConstActors.Add(Actor);
	Params.AddIgnoredActors(ConstActors);
	int32 AfterConst = Params.GetIgnoredActors().Num();
	return AfterActors == 1 && AfterConst >= AfterActors;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-component
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredComponentNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-component
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredComponentNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
	}
	FComponentQueryParams Params;
	UPrimitiveComponent NullComponent;
	Params.AddIgnoredComponent(NullComponent);
	int32 AfterNull = Params.GetIgnoredComponents().Num();
	Params.AddIgnoredComponent(IgnoreComponent);
	int32 AfterComponent = Params.GetIgnoredComponents().Num();
	return AfterNull == 0 && AfterComponent == 1;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-components
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredComponentsNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
	}
	FComponentQueryParams Params;
	TArray<UPrimitiveComponent> Components;
	Components.Add(IgnoreComponent);
	UPrimitiveComponent NullComponent;
	Components.Add(NullComponent);
	Params.AddIgnoredComponents(Components);
	int32 After = Params.GetIgnoredComponents().Num();
	return After == 1;
}
/** @end */
/**
 * @begin FCollisionQueryParams-MutationAndLifecycle_02-add-ignored-component-likely-duplicated-root
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveAddIgnoredComponentLikelyDuplicatedRootNominal
 * @summary SetupOwner=Runner.
 * @covers FCollisionQueryParams.add-ignored-component-likely-duplicated-root
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddIgnoredComponentLikelyDuplicatedRootNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_MutationAndLifecycle_02 setup: required IgnoreComponent is null");
	}
	FComponentQueryParams Params;
	UPrimitiveComponent NullComponent;
	Params.AddIgnoredComponent_LikelyDuplicatedRoot(NullComponent);
	int32 AfterNull = Params.GetIgnoredComponents().Num();
	Params.AddIgnoredComponent_LikelyDuplicatedRoot(IgnoreComponent);
	int32 AfterRoot = Params.GetIgnoredComponents().Num();
	Params.AddIgnoredComponent_LikelyDuplicatedRoot(IgnoreComponent);
	int32 AfterDuplicate = Params.GetIgnoredComponents().Num();
	return AfterNull == 0 && AfterRoot == 1 && AfterDuplicate >= AfterRoot;
}
/** @end */
/**
 * @begin add-object-types-to-query
 * @summary returns a new container.
 * @topic Unreal
 */
/**
 * @function ObserveAddObjectTypesToQueryNominal
 * @summary returns a new container.
 * @covers FCollisionQueryParams.add-object-types-to-query
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddObjectTypesToQueryNominal()
{
	FCollisionObjectQueryParams Params;
	bool bEmptyInvalid = Params.IsValid();
	Params.AddObjectTypesToQuery(ECollisionChannel::WorldStatic);
	bool bWorldStaticValid = Params.IsValid();
	Params.AddObjectTypesToQuery(ECollisionChannel::Pawn);
	int64 Bits = Params.GetObjectTypesToQuery();
	return !bEmptyInvalid && bWorldStaticValid && Bits != 0;
}
/** @end */
/**
 * @begin remove-object-types-to-query
 * @summary returns a new container.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveObjectTypesToQueryNominal
 * @summary returns a new container.
 * @covers FCollisionQueryParams.remove-object-types-to-query
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveObjectTypesToQueryNominal()
{
	FCollisionObjectQueryParams Params;
	Params.AddObjectTypesToQuery(ECollisionChannel::WorldStatic);
	Params.AddObjectTypesToQuery(ECollisionChannel::Pawn);
	Params.RemoveObjectTypesToQuery(ECollisionChannel::Pawn);
	bool bStillValid = Params.IsValid();
	Params.RemoveObjectTypesToQuery(ECollisionChannel::WorldStatic);
	bool bEmptyAfterRemove = Params.IsValid();
	return bStillValid && !bEmptyAfterRemove;
}
/** @end */
/**
 * @begin set-object-types-to-query
 * @summary returns a new container.
 * @topic Unreal
 */
/**
 * @function ObserveSetObjectTypesToQueryNominal
 * @summary returns a new container.
 * @covers FCollisionQueryParams.set-object-types-to-query
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetObjectTypesToQueryNominal()
{
	FCollisionObjectQueryParams Params;
	Params.SetObjectTypesToQuery(1);
	int64 One = Params.GetObjectTypesToQuery();
	bool bOneValid = Params.IsValid();
	Params.SetObjectTypesToQuery(0);
	int64 Zero = Params.GetObjectTypesToQuery();
	bool bZeroInvalid = Params.IsValid();
	return One == 1 && bOneValid && Zero == 0 && !bZeroInvalid;
}
/** @end */
/**
 * @begin set-response
 * @summary returns a new container.
 * @topic Unreal
 */
/**
 * @function ObserveSetResponseNominal
 * @summary returns a new container.
 * @covers FCollisionQueryParams.set-response
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetResponseNominal()
{
	FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
	bool bChanged = Responses.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	bool bRepeatUnchanged = Responses.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	ECollisionResponse After = Responses.GetResponse(ECollisionChannel::Visibility);
	return bChanged && !bRepeatUnchanged && After == ECollisionResponse::ECR_Block;
}
/** @end */
/**
 * @begin set-all-channels
 * @summary returns a new container.
 * @topic Unreal
 */
/**
 * @function ObserveSetAllChannelsNominal
 * @summary returns a new container.
 * @covers FCollisionQueryParams.set-all-channels
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetAllChannelsNominal()
{
	FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
	bool bChanged = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
	bool bRepeatUnchanged = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
	ECollisionResponse Visibility = Responses.GetResponse(ECollisionChannel::Visibility);
	ECollisionResponse WorldStatic = Responses.GetResponse(ECollisionChannel::WorldStatic);
	return bChanged && !bRepeatUnchanged && Visibility == ECollisionResponse::ECR_Block && WorldStatic == ECollisionResponse::ECR_Block;
}
/** @end */
/**
 * @begin create-min-container
 * @summary returns a new container.
 * @topic Unreal
 */
/**
 * @function ObserveCreateMinContainerNominal
 * @summary returns a new container.
 * @covers FCollisionQueryParams.create-min-container
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCreateMinContainerNominal()
{
	FCollisionResponseContainer A(ECollisionResponse::ECR_Block);
	A.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Overlap);
	A.SetResponse(ECollisionChannel::WorldStatic, ECollisionResponse::ECR_Ignore);
	FCollisionResponseContainer B(ECollisionResponse::ECR_Ignore);
	B.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	FCollisionResponseContainer Min = FCollisionResponseContainer::CreateMinContainer(A, B);
	ECollisionResponse Visibility = Min.GetResponse(ECollisionChannel::Visibility);
	ECollisionResponse WorldStatic = Min.GetResponse(ECollisionChannel::WorldStatic);
	return Visibility == ECollisionResponse::ECR_Overlap && WorldStatic == ECollisionResponse::ECR_Ignore;
}
/** @end */
/**
 * @begin equerymobilitytype-any-distinct-static
 * @summary EQueryMobilityType::Any is distinct from Static.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary EQueryMobilityType::Any is distinct from Static.
 * @covers FCollisionQueryParams.equerymobilitytype-any-distinct-static
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	EQueryMobilityType Any = EQueryMobilityType::Any;
	return Any != EQueryMobilityType::Static;
}
/** @end */
/**
 * @begin equerymobilitytype-static-distinct-dynamic
 * @summary EQueryMobilityType::Static is distinct from Dynamic.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary EQueryMobilityType::Static is distinct from Dynamic.
 * @covers FCollisionQueryParams.equerymobilitytype-static-distinct-dynamic
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	EQueryMobilityType Static = EQueryMobilityType::Static;
	return Static != EQueryMobilityType::Dynamic;
}
/** @end */
/**
 * @begin equerymobilitytype-dynamic-distinct-any
 * @summary EQueryMobilityType::Dynamic is distinct from Any.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary EQueryMobilityType::Dynamic is distinct from Any.
 * @covers FCollisionQueryParams.equerymobilitytype-dynamic-distinct-any
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	EQueryMobilityType Dynamic = EQueryMobilityType::Dynamic;
	return Dynamic != EQueryMobilityType::Any;
}
/** @end */
/**
 * @begin ecollisionobjectqueryinittype-allobjects-distinct-allstaticobjects
 * @summary ECollisionObjectQueryInitType::AllObjects is distinct from AllStaticObjects.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary ECollisionObjectQueryInitType::AllObjects is distinct from AllStaticObjects.
 * @covers FCollisionQueryParams.ecollisionobjectqueryinittype-allobjects-distinct-allstaticobjects
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface006Nominal()
{
	ECollisionObjectQueryInitType AllObjects = ECollisionObjectQueryInitType::AllObjects;
	return AllObjects != ECollisionObjectQueryInitType::AllStaticObjects;
}
/** @end */
/**
 * @begin ecollisionobjectqueryinittype-allstaticobjects-distinct-alldynamicobjects
 * @summary ECollisionObjectQueryInitType::AllStaticObjects is distinct from AllDynamicObjects.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary ECollisionObjectQueryInitType::AllStaticObjects is distinct from AllDynamicObjects.
 * @covers FCollisionQueryParams.ecollisionobjectqueryinittype-allstaticobjects-distinct-alldynamicobjects
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface007Nominal()
{
	ECollisionObjectQueryInitType AllStaticObjects = ECollisionObjectQueryInitType::AllStaticObjects;
	return AllStaticObjects != ECollisionObjectQueryInitType::AllDynamicObjects;
}
/** @end */
/**
 * @begin ecollisionobjectqueryinittype-alldynamicobjects-distinct-allobjects
 * @summary ECollisionObjectQueryInitType::AllDynamicObjects is distinct from AllObjects.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary ECollisionObjectQueryInitType::AllDynamicObjects is distinct from AllObjects.
 * @covers FCollisionQueryParams.ecollisionobjectqueryinittype-alldynamicobjects-distinct-allobjects
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface008Nominal()
{
	ECollisionObjectQueryInitType AllDynamicObjects = ECollisionObjectQueryInitType::AllDynamicObjects;
	return AllDynamicObjects != ECollisionObjectQueryInitType::AllObjects;
}
/** @end */
/**
 * @begin oracle-tostring-non-empty
 * @summary Oracle: ToString is non-empty.
 * @topic Unreal
 */
/**
 * @function ObserveSurface017Nominal
 * @summary Oracle: ToString is non-empty.
 * @covers FCollisionQueryParams.oracle-tostring-non-empty
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface017Nominal()
{
	FCollisionQueryParams DefaultQueryParams = FCollisionQueryParams::DefaultQueryParam;
	FString Text = DefaultQueryParams.ToString();
	return DefaultQueryParams.TraceTag == NAME_None && DefaultQueryParams.GetIgnoredActors().Num() == 0 && Text.Len() > 0;
}
/** @end */
/**
 * @begin FCollisionQueryParams-NamespaceAndGlobalFunctions_01-oracle-tostring-non-empty
 * @summary Oracle: ToString is non-empty.
 * @topic Unreal
 */
/**
 * @function ObserveSurface024Nominal
 * @summary Oracle: ToString is non-empty.
 * @covers FCollisionQueryParams.oracle-tostring-non-empty
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface024Nominal()
{
	FComponentQueryParams DefaultComponentParams = FComponentQueryParams::DefaultComponentQueryParams;
	FString Text = DefaultComponentParams.ToString();
	return DefaultComponentParams.TraceTag == NAME_None && DefaultComponentParams.GetIgnoredActors().Num() == 0 && Text.Len() > 0;
}
/** @end */
/**
 * @begin surface-028
 * @summary container.
 * @topic Unreal
 */
/**
 * @function ObserveSurface028Nominal
 * @summary container.
 * @covers FCollisionQueryParams.surface-028
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface028Nominal()
{
	FCollisionResponseParams DefaultResponseParam = FCollisionResponseParams::DefaultResponseParam;
	FCollisionResponseParams Copied = DefaultResponseParam;
	FCollisionResponseContainer DefaultContainer = FCollisionResponseContainer::GetDefaultResponseContainer();
	FCollisionResponseParams FromDefault(DefaultContainer);
	return DefaultContainer.GetResponse(ECollisionChannel::Visibility) == ECollisionResponse::ECR_Block && DefaultContainer.GetResponse(ECollisionChannel::WorldStatic) == ECollisionResponse::ECR_Block;
}
/** @end */
/**
 * @begin oracle-isvalid-false-bitfield
 * @summary Oracle: IsValid is false and the bitfield is 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface031Nominal
 * @summary Oracle: IsValid is false and the bitfield is 0.
 * @covers FCollisionQueryParams.oracle-isvalid-false-bitfield
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface031Nominal()
{
	FCollisionObjectQueryParams DefaultObjectParams = FCollisionObjectQueryParams::DefaultObjectQueryParam;
	return !DefaultObjectParams.IsValid() && DefaultObjectParams.GetObjectTypesToQuery() == 0;
}
/** @end */
/**
 * @begin equality
 * @summary Equality does not mutate either container.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Equality does not mutate either container.
 * @covers FCollisionQueryParams.equality
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FCollisionResponseContainer Left(ECollisionResponse::ECR_Ignore);
	FCollisionResponseContainer Right(ECollisionResponse::ECR_Ignore);
	bool bSame = Left == Right;
	Left.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	bool bDifferent = Left == Right;
	FCollisionResponseContainer Copy(ECollisionResponse::ECR_Ignore);
	Copy.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	bool bCopyMatches = Left == Copy;
	return bSame && !bDifferent && bCopyMatches;
}
/** @end */
/**
 * @begin get-ignored-components
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveGetIgnoredComponentsNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.get-ignored-components
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetIgnoredComponentsNominal(UPrimitiveComponent IgnoreComponent)
{
	if (IgnoreComponent is null)
	{
		throw("TS_FCollisionQueryParams_Queries_01 setup: required IgnoreComponent is null");
	}
	FCollisionQueryParams QueryParams;
	TArray<uint32> EmptyQuery = QueryParams.GetIgnoredComponents();
	QueryParams.AddIgnoredComponent(IgnoreComponent);
	TArray<uint32> QueryIds = QueryParams.GetIgnoredComponents();

	FComponentQueryParams ComponentParams;
	TArray<uint32> EmptyComponent = ComponentParams.GetIgnoredComponents();
	ComponentParams.AddIgnoredComponent(IgnoreComponent);
	TArray<uint32> ComponentIds = ComponentParams.GetIgnoredComponents();
	return EmptyQuery.Num() == 0 && QueryIds.Num() == 1 && EmptyComponent.Num() == 0 && ComponentIds.Num() == 1;
}
/** @end */
/**
 * @begin get-ignored-actors
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveGetIgnoredActorsNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.get-ignored-actors
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetIgnoredActorsNominal(AActor Actor)
{
	if (Actor is null)
	{
		throw("TS_FCollisionQueryParams_Queries_01 setup: required Actor is null");
	}
	FCollisionQueryParams QueryParams;
	TArray<uint32> EmptyQuery = QueryParams.GetIgnoredActors();
	QueryParams.AddIgnoredActor(Actor);
	TArray<uint32> QueryIds = QueryParams.GetIgnoredActors();

	FComponentQueryParams ComponentParams;
	TArray<uint32> EmptyComponent = ComponentParams.GetIgnoredActors();
	ComponentParams.AddIgnoredActor(Actor);
	TArray<uint32> ComponentIds = ComponentParams.GetIgnoredActors();
	return EmptyQuery.Num() == 0 && QueryIds.Num() == 1 && EmptyComponent.Num() == 0 && ComponentIds.Num() == 1;
}
/** @end */
/**
 * @begin get-object-types-to-query
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveGetObjectTypesToQueryNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.get-object-types-to-query
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetObjectTypesToQueryNominal()
{
	FCollisionObjectQueryParams Empty;
	int64 EmptyBits = Empty.GetObjectTypesToQuery();
	FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
	int64 AllBits = AllObjects.GetObjectTypesToQuery();
	return EmptyBits == 0 && AllBits != 0;
}
/** @end */
/**
 * @begin get-query-bitfield-64
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveGetQueryBitfield64Nominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.get-query-bitfield-64
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetQueryBitfield64Nominal()
{
	FCollisionObjectQueryParams Empty;
	int64 EmptyBits = Empty.GetQueryBitfield64();
	FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
	int64 WorldStaticBits = WorldStatic.GetQueryBitfield64();
	return EmptyBits == 0 && WorldStaticBits != 0;
}
/** @end */
/**
 * @begin is-valid
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.is-valid
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidNominal()
{
	FCollisionObjectQueryParams Empty;
	bool bEmptyInvalid = Empty.IsValid();
	FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
	bool bWorldStaticValid = WorldStatic.IsValid();
	FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
	bool bAllObjectsValid = AllObjects.IsValid();
	return !bEmptyInvalid && bWorldStaticValid && bAllObjectsValid;
}
/** @end */
/**
 * @begin is-valid-object-query
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidObjectQueryNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.is-valid-object-query
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidObjectQueryNominal()
{
	bool bWorldStatic = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::WorldStatic);
	bool bPawn = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::Pawn);
	bool bVisibility = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::Visibility);
	bool bCamera = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::Camera);
	return bWorldStatic && bPawn && !bVisibility && !bCamera;
}
/** @end */
/**
 * @begin get-collision-channel-from-overlap-filter
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveGetCollisionChannelFromOverlapFilterNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.get-collision-channel-from-overlap-filter
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCollisionChannelFromOverlapFilterNominal()
{
	ECollisionObjectQueryInitType All = FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption::OverlapFilter_All);
	ECollisionObjectQueryInitType DynamicOnly = FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption::OverlapFilter_DynamicOnly);
	ECollisionObjectQueryInitType StaticOnly = FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption::OverlapFilter_StaticOnly);
	return All == ECollisionObjectQueryInitType::AllObjects && DynamicOnly == ECollisionObjectQueryInitType::AllDynamicObjects && StaticOnly == ECollisionObjectQueryInitType::AllStaticObjects;
}
/** @end */
/**
 * @begin get-response
 * @summary is a namespace helper.
 * @topic Unreal
 */
/**
 * @function ObserveGetResponseNominal
 * @summary is a namespace helper.
 * @covers FCollisionQueryParams.get-response
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetResponseNominal()
{
	FCollisionResponseContainer IgnoreAll(ECollisionResponse::ECR_Ignore);
	ECollisionResponse VisibilityIgnore = IgnoreAll.GetResponse(ECollisionChannel::Visibility);
	IgnoreAll.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
	ECollisionResponse VisibilityBlock = IgnoreAll.GetResponse(ECollisionChannel::Visibility);
	ECollisionResponse WorldStatic = IgnoreAll.GetResponse(ECollisionChannel::WorldStatic);
	return VisibilityIgnore == ECollisionResponse::ECR_Ignore && VisibilityBlock == ECollisionResponse::ECR_Block && WorldStatic == ECollisionResponse::ECR_Ignore;
}
/** @end */
/**
 * @begin get-default-response-container
 * @summary Do not assume exclusive ownership.
 * @topic Unreal
 */
/**
 * @function ObserveGetDefaultResponseContainerNominal
 * @summary Do not assume exclusive ownership.
 * @covers FCollisionQueryParams.get-default-response-container
 * @inputs FCollisionQueryParams values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDefaultResponseContainerNominal()
{
	FCollisionResponseContainer First = FCollisionResponseContainer::GetDefaultResponseContainer();
	FCollisionResponseContainer Second = FCollisionResponseContainer::GetDefaultResponseContainer();
	FCollisionResponseContainer IgnoreAll(ECollisionResponse::ECR_Ignore);
	ECollisionResponse Visibility = First.GetResponse(ECollisionChannel::Visibility);
	return First == Second && !(First == IgnoreAll) && Visibility == ECollisionResponse::ECR_Block;
}
/** @end */
