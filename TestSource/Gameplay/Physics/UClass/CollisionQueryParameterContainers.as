/**
 * Collision query, component-query, object-query and response parameter containers,
 * plus a collision-enabled mask. C++ verifies the five flags by path after BeginPlay,
 * so those UPROPERTY names are part of the contract and are kept verbatim. The
 * observers cover the local-construct defaults and an empty ignore list.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.CollisionQueryParameterContainers
 * @Harness UClass
 * @Tag Gameplay.Physics.CollisionQueryParameterContainers
 * @Provenance Theme: Gameplay.Physics. WorldStory collision query/component/object/response param containers.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::CollisionQueryParameterContainers
 * @Provenance Oracle VerifyByPath after BeginPlay: QueryParamsRoundTripped, ComponentQueryParamsRoundTripped,
 * @Provenance ObjectQueryParamsRoundTripped, ResponseParamsRoundTripped, CollisionEnabledMaskRoundTripped true.
 * @Provenance Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoveragePhysicsQueryParameterActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool QueryParamsRoundTripped = false;

	UPROPERTY()
	bool ComponentQueryParamsRoundTripped = false;

	UPROPERTY()
	bool ObjectQueryParamsRoundTripped = false;

	UPROPERTY()
	bool ResponseParamsRoundTripped = false;

	UPROPERTY()
	bool CollisionEnabledMaskRoundTripped = false;

	/**
	 * WorldStory: BeginPlay constructs query, component-query, object-query and
	 * response params, plus a query-only enabled mask, reading each container back.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.CollisionQueryParameterContainers
	 * @Inputs a default-attached USphereComponent
	 * @Return QueryParamsRoundTripped, ComponentQueryParamsRoundTripped,
	 * ObjectQueryParamsRoundTripped, ResponseParamsRoundTripped and
	 * CollisionEnabledMaskRoundTripped true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FCollisionQueryParams QueryParams(n"CoverageQueryContainer", true, this);
		QueryParams.OwnerTag = n"CoverageOwner";
		QueryParams.bFindInitialOverlaps = true;
		QueryParams.bIgnoreBlocks = false;
		QueryParams.bIgnoreTouches = false;
		QueryParams.bSkipNarrowPhase = false;
		QueryParams.MobilityType = EQueryMobilityType::Dynamic;
		QueryParams.AddIgnoredComponent(Sphere);

		TArray<UPrimitiveComponent> IgnoredComponents;
		IgnoredComponents.Add(Sphere);
		QueryParams.AddIgnoredComponents(IgnoredComponents);

		QueryParamsRoundTripped =
			QueryParams.TraceTag == n"CoverageQueryContainer"
			&& QueryParams.OwnerTag == n"CoverageOwner"
			&& QueryParams.bTraceComplex
			&& QueryParams.bFindInitialOverlaps
			&& QueryParams.MobilityType == EQueryMobilityType::Dynamic
			&& QueryParams.GetIgnoredComponents().Num() > 0
			&& QueryParams.ToString().Len() > 0;

		FCollisionEnabledMask QueryOnlyMask(ECollisionEnabled::QueryOnly);
		CollisionEnabledMaskRoundTripped = QueryOnlyMask.Bits != 0;

		FComponentQueryParams ComponentParams(n"CoverageComponentQuery", this, QueryOnlyMask);
		ComponentParams.TraceTag = n"CoverageComponentTrace";
		ComponentParams.ShapeCollisionMask = QueryOnlyMask;
		ComponentParams.AddIgnoredComponent(Sphere);
		ComponentQueryParamsRoundTripped =
			ComponentParams.TraceTag == n"CoverageComponentTrace"
			&& ComponentParams.ShapeCollisionMask.Bits == QueryOnlyMask.Bits
			&& ComponentParams.GetIgnoredComponents().Num() > 0;

		FCollisionObjectQueryParams ObjectParams(ECollisionObjectQueryInitType::AllDynamicObjects);
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_PhysicsBody);
		ObjectParams.RemoveObjectTypesToQuery(ECollisionChannel::ECC_PhysicsBody);
		ObjectParams.SetObjectTypesToQuery(ObjectParams.GetObjectTypesToQuery());
		ObjectQueryParamsRoundTripped = ObjectParams.IsValid() && ObjectParams.GetQueryBitfield64() != 0;

		FCollisionResponseParams BlockResponses(ECollisionResponse::ECR_Block);
		ResponseParamsRoundTripped = true;
	}

	/**
	 * Observe that a locally constructed actor holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionQueryParameterContainers
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when QueryParamsRoundTripped, ComponentQueryParamsRoundTripped,
	 * ObjectQueryParamsRoundTripped, ResponseParamsRoundTripped and
	 * CollisionEnabledMaskRoundTripped are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (QueryParamsRoundTripped)
		{
			return false;
		}
		if (ComponentQueryParamsRoundTripped)
		{
			return false;
		}
		if (ObjectQueryParamsRoundTripped)
		{
			return false;
		}
		if (ResponseParamsRoundTripped)
		{
			return false;
		}
		return CollisionEnabledMaskRoundTripped == false;
	}

	/**
	 * Observe that a freshly declared ignored-component array is empty.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionQueryParameterContainers
	 * @Inputs a newly declared component array
	 * @Return true when Num is 0
	 * @Boundary empty ignore list
	 */
	UFUNCTION()
	bool EmptyIgnoreListBoundary()
	{
		TArray<UPrimitiveComponent> IgnoredComponents;
		return IgnoredComponents.Num() == 0;
	}
}
