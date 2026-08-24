// Theme: World.Component. WorldStory: built-in object/trace channel matrix.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionChannelMatrixReadback
// sha256=5117df606e9979057d26eb49422fa638be8e224375b5384aef6901f1cf76926c; lines 787-844.
// Oracle VerifyByPath BuiltInObjectTypesRoundTripped, BuiltInTraceChannelsRoundTripped,
// AllResponsesRoundTripped true. Extra: local construct flags false, MeshComp null.
// FixtureIsolated.

UCLASS()
class ACoveragePrimitiveCollisionChannelMatrixActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool BuiltInObjectTypesRoundTripped = false;

	UPROPERTY()
	bool BuiltInTraceChannelsRoundTripped = false;

	UPROPERTY()
	bool AllResponsesRoundTripped = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldStatic);
		bool bWorldStatic = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldStatic;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		bool bWorldDynamic = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_Pawn);
		bool bPawn = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_Pawn;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_PhysicsBody);
		bool bPhysicsBody = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_PhysicsBody;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_Vehicle);
		bool bVehicle = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_Vehicle;
		MeshComp.SetCollisionObjectType(ECollisionChannel::ECC_Destructible);
		bool bDestructible = MeshComp.GetCollisionObjectType() == ECollisionChannel::ECC_Destructible;
		BuiltInObjectTypesRoundTripped =
			bWorldStatic
			&& bWorldDynamic
			&& bPawn
			&& bPhysicsBody
			&& bVehicle
			&& bDestructible;

		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
		bool bVisibility = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block;
		MeshComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		bool bCamera = MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;
		BuiltInTraceChannelsRoundTripped = bVisibility && bCamera;

		MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
		AllResponsesRoundTripped =
			MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_WorldStatic) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_WorldDynamic) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_PhysicsBody) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Vehicle) == ECollisionResponse::ECR_Ignore
			&& MeshComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Destructible) == ECollisionResponse::ECR_Ignore;
	}
}

bool Observe_CollisionChannelMatrix_DefaultFalse(ACoveragePrimitiveCollisionChannelMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveCollisionChannelMatrixReadback setup: required Actor is null");
	}
	return !Actor.BuiltInObjectTypesRoundTripped
		&& !Actor.BuiltInTraceChannelsRoundTripped
		&& !Actor.AllResponsesRoundTripped
		&& Actor.MeshComp == nullptr;
}

bool Observe_CollisionChannelMatrix_CopyIndependence(ACoveragePrimitiveCollisionChannelMatrixActor First, ACoveragePrimitiveCollisionChannelMatrixActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveCollisionChannelMatrixReadback setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveCollisionChannelMatrixReadback setup: required Second is null");
	}
	First.AllResponsesRoundTripped = true;
	return First.AllResponsesRoundTripped && !Second.AllResponsesRoundTripped;
}
