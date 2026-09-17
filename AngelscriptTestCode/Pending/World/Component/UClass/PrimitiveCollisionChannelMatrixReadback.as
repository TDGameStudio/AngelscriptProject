/**
 * @version v1
 * @summary The built-in object-type and trace-channel collision matrix read back off a static mesh component. C++ verifies the three flags by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary The built-in object-type and trace-channel collision matrix read back off a static mesh component. C++ verifies the three flags by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay walks every built-in object type, both built-in trace
	 * channels, then a blanket response reset and reads all of them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionChannelMatrixReadback
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return all three flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionChannelMatrixReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (BuiltInObjectTypesRoundTripped)
		{
			return false;
		}
		if (BuiltInTraceChannelsRoundTripped)
		{
			return false;
		}
		if (AllResponsesRoundTripped)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionChannelMatrixReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionChannelMatrixActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionChannelMatrixReadback setup: required Second is null");
		}
		AllResponsesRoundTripped = true;

		if (!AllResponsesRoundTripped)
		{
			return false;
		}
		return !Second.AllResponsesRoundTripped;
	}
}
/** @end */
