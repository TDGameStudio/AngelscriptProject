/**
 * @version v1
 * @summary Observe default/copy constructors for query, component, and response params, plus FCollisionEnabledMask construction and Bits.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe default/copy constructors for query, component, and response params, plus FCollisionEnabledMask construction and Bits.
 * @topic Baseline
 */
// The bool return is the runner-readable oracle.
// AS-facing API: FCollisionQueryParams Params();
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

namespace TS_FCollisionQueryParams_Behavior_01
{
	// FCollisionQueryParams/FComponentQueryParams copy plus FCollisionResponseParams from ECR_Block and a Visibility-Block container. Oracle: copied TraceTags and container Visibility is Block. Value copies.
	bool Observe_Params_Nominal()
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

	// FCollisionEnabledMask() vs QueryOnly vs QueryAndPhysics. Oracle: empty Bits==0, QueryOnly Bits!=0, physics Bits differ. Packed mask value.
	bool Observe_Mask_Nominal()
	{
		FCollisionEnabledMask EmptyMask;
		FCollisionEnabledMask QueryOnlyMask(ECollisionEnabled::QueryOnly);
		FCollisionEnabledMask PhysicsMask(ECollisionEnabled::QueryAndPhysics);
		return EmptyMask.Bits == 0 && QueryOnlyMask.Bits != 0 && PhysicsMask.Bits != 0 && PhysicsMask.Bits != QueryOnlyMask.Bits;
	}

	// FCollisionEnabledMask.Bits default, assigned 3, and QueryOnly. Oracle: 0 then 3 then nonzero. Field write is visible on the mask.
	bool Observe_Surface020_Nominal()
	{
		FCollisionEnabledMask Mask;
		int8 EmptyBits = Mask.Bits;
		Mask.Bits = 3;
		int8 Assigned = Mask.Bits;
		FCollisionEnabledMask QueryOnlyMask(ECollisionEnabled::QueryOnly);
		int8 QueryOnlyBits = QueryOnlyMask.Bits;
		return EmptyBits == 0 && Assigned == 3 && QueryOnlyBits != 0;
	}
}
/** @end */
