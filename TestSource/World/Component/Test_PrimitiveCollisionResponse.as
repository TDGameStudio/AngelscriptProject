// Theme: World.Component. WorldStory: SetCollisionResponseToChannel / AllChannels
// and SetCollisionObjectType round-trip.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionResponse
// sha256=ab4844fe77a3fa82ec6ba1cd5b3889d1c25d9390b4bc862beece911b7d4f91ea; lines 690-741.
// Oracle VerifyByPath ResponseSet, BlockResponseSet, OverlapResponseSet,
// IgnoreResponseSet, AllChannelsSet, ObjectTypeSet all true. Extra: local
// construct all false, MeshComp null. FixtureIsolated.

UCLASS()
class ACoveragePrimitiveCollisionResponseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool ResponseSet = false;

	UPROPERTY()
	bool AllChannelsSet = false;

	UPROPERTY()
	bool ObjectTypeSet = false;

	UPROPERTY()
	bool BlockResponseSet = false;

	UPROPERTY()
	bool OverlapResponseSet = false;

	UPROPERTY()
	bool IgnoreResponseSet = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set response to specific channel
		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Block);
		BlockResponseSet = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block;

		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Overlap);
		OverlapResponseSet = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Overlap;

		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		IgnoreResponseSet = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;
		ResponseSet = BlockResponseSet && OverlapResponseSet && IgnoreResponseSet;

		// Set response to all channels
		MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
		AllChannelsSet =
			MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Block;

		// Set object type
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		ObjectTypeSet = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic;
	}
}

bool Observe_CollisionResponse_DefaultFalse(ACoveragePrimitiveCollisionResponseActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveCollisionResponse setup: required Actor is null");
	}
	return !Actor.ResponseSet
		&& !Actor.AllChannelsSet
		&& !Actor.ObjectTypeSet
		&& !Actor.BlockResponseSet
		&& !Actor.OverlapResponseSet
		&& !Actor.IgnoreResponseSet
		&& Actor.MeshComp == nullptr;
}

bool Observe_CollisionResponse_CopyIndependence(ACoveragePrimitiveCollisionResponseActor First, ACoveragePrimitiveCollisionResponseActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveCollisionResponse setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveCollisionResponse setup: required Second is null");
	}
	First.ResponseSet = true;
	First.ObjectTypeSet = true;
	return First.ResponseSet && First.ObjectTypeSet && !Second.ResponseSet && !Second.ObjectTypeSet;
}
