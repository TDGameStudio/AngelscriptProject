// Theme: World.Component. WorldStory: FCollisionObjectQueryParams and
// FCollisionResponseContainer round-trip. PlannedSymbols include Responses.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveTraceObjectQueryReadback
// sha256=9311947e3d5fe0a1a1097e3973debaa906a945144ee16ebb5e2619a2a7cecad1; lines 905-969.
// Oracle VerifyByPath TraceChannelsReadable, ObjectQueryChannelsValidated,
// ObjectQueryParamsRoundTripped, ResponseContainerRoundTripped true.
// Extra: local construct flags false, SphereComp null. FixtureIsolated.

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
}

bool Observe_TraceObjectQuery_DefaultFalse(ACoveragePrimitiveTraceObjectQueryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveTraceObjectQueryReadback setup: required Actor is null");
	}
	return !Actor.TraceChannelsReadable
		&& !Actor.ObjectQueryChannelsValidated
		&& !Actor.ObjectQueryParamsRoundTripped
		&& !Actor.ResponseContainerRoundTripped
		&& Actor.SphereComp == nullptr;
}

bool Observe_TraceObjectQuery_CopyIndependence(ACoveragePrimitiveTraceObjectQueryActor First, ACoveragePrimitiveTraceObjectQueryActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveTraceObjectQueryReadback setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveTraceObjectQueryReadback setup: required Second is null");
	}
	First.TraceChannelsReadable = true;
	return First.TraceChannelsReadable && !Second.TraceChannelsReadable;
}
