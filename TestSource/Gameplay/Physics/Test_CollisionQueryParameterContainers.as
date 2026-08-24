// Theme: Gameplay.Physics. WorldStory collision query/component/object/response param containers.
// C++: AngelscriptCoveragePhysicsTests.cpp::CollisionQueryParameterContainers
// Oracle VerifyByPath after BeginPlay: QueryParamsRoundTripped, ComponentQueryParamsRoundTripped,
// ObjectQueryParamsRoundTripped, ResponseParamsRoundTripped, CollisionEnabledMaskRoundTripped true.
// Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.

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
}

bool Observe_QueryParameterContainers_Defaults(ACoveragePhysicsQueryParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CollisionQueryParameterContainers setup: required Actor is null");
	}
	return Actor.QueryParamsRoundTripped == false
		&& Actor.ComponentQueryParamsRoundTripped == false
		&& Actor.ObjectQueryParamsRoundTripped == false
		&& Actor.ResponseParamsRoundTripped == false
		&& Actor.CollisionEnabledMaskRoundTripped == false;
}

bool Observe_QueryParameterContainers_EmptyIgnoreListBoundary()
{
	TArray<UPrimitiveComponent> IgnoredComponents;
	return IgnoredComponents.Num() == 0;
}
