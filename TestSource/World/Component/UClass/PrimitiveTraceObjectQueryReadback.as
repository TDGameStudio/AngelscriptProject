/**
 * FCollisionObjectQueryParams and FCollisionResponseContainer round-tripped, plus
 * the trace channel enums read. C++ verifies the four flags by path. The observers
 * cover the local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.PrimitiveTraceObjectQueryReadback
 * @Harness UClass
 * @Tag World.Component.PrimitiveTraceObjectQueryReadback
 * @Provenance Theme: World.Component. WorldStory: FCollisionObjectQueryParams and
 * @Provenance FCollisionResponseContainer round-trip. PlannedSymbols include Responses.
 * @Provenance C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveTraceObjectQueryReadback
 * @Provenance sha256=9311947e3d5fe0a1a1097e3973debaa906a945144ee16ebb5e2619a2a7cecad1; lines 905-969.
 * @Provenance Oracle VerifyByPath TraceChannelsReadable, ObjectQueryChannelsValidated,
 * @Provenance ObjectQueryParamsRoundTripped, ResponseContainerRoundTripped true.
 * @Provenance Extra: local construct flags false, SphereComp null. FixtureIsolated.
 */

UCLASS()
class ACoveragePrimitiveTraceObjectQueryActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool TraceChannelsReadable = false;

	UPROPERTY()
	bool ObjectQueryChannelsValidated = false;

	UPROPERTY()
	bool ObjectQueryParamsRoundTripped = false;

	UPROPERTY()
	bool ResponseContainerRoundTripped = false;

	/**
	 * WorldStory: BeginPlay reads both trace channels, validates which channels are
	 * legal object queries, round-trips an object query bitfield and a response
	 * container, then resets the sphere's own collision state.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveTraceObjectQueryReadback
	 * @Inputs a default-attached USphereComponent
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TraceChannelsReadable =
			int(ECollisionChannel::ECC_Visibility) >= 0
			&& int(ECollisionChannel::ECC_Camera) >= 0;

		ObjectQueryChannelsValidated =
			FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_WorldStatic)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_WorldDynamic)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Pawn)
			&& FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_PhysicsBody)
			&& !FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Visibility)
			&& !FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::ECC_Camera);

		FCollisionObjectQueryParams ObjectParams;
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldStatic);
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);
		ObjectParams.AddObjectTypesToQuery(ECollisionChannel::ECC_Pawn);
		int64 BeforeRemove = ObjectParams.GetQueryBitfield64();
		ObjectParams.RemoveObjectTypesToQuery(ECollisionChannel::ECC_Pawn);
		int64 AfterRemove = ObjectParams.GetQueryBitfield64();
		ObjectQueryParamsRoundTripped =
			ObjectParams.IsValid()
			&& BeforeRemove != 0
			&& AfterRemove != 0
			&& BeforeRemove != AfterRemove
			&& ObjectParams.GetObjectTypesToQuery() == AfterRemove;

		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		bool bSetVisibility = Responses.SetResponse(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
		bool bSetPawn = Responses.SetResponse(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Overlap);
		bool bSetAll = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
		ResponseContainerRoundTripped =
			bSetVisibility
			&& bSetPawn
			&& bSetAll
			&& Responses.GetResponse(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Block;

		SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		SphereComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveTraceObjectQueryReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (TraceChannelsReadable)
		{
			return false;
		}
		if (ObjectQueryChannelsValidated)
		{
			return false;
		}
		if (ObjectQueryParamsRoundTripped)
		{
			return false;
		}
		if (ResponseContainerRoundTripped)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveTraceObjectQueryReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveTraceObjectQueryActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveTraceObjectQueryReadback setup: required Second is null");
		}
		TraceChannelsReadable = true;

		if (!TraceChannelsReadable)
		{
			return false;
		}
		return !Second.TraceChannelsReadable;
	}
}
