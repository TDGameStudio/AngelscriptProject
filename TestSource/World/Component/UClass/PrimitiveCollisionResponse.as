/**
 * Per-channel and all-channel collision responses plus the object type, all read
 * back off a static mesh component. C++ verifies the six flags by path. The
 * observers cover the local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.PrimitiveCollisionResponse
 * @Harness UClass
 * @Tag World.Component.PrimitiveCollisionResponse
 * @Provenance Theme: World.Component. WorldStory: SetCollisionResponseToChannel / AllChannels
 * @Provenance and SetCollisionObjectType round-trip.
 * @Provenance C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionResponse
 * @Provenance sha256=ab4844fe77a3fa82ec6ba1cd5b3889d1c25d9390b4bc862beece911b7d4f91ea; lines 690-741.
 * @Provenance Oracle VerifyByPath ResponseSet, BlockResponseSet, OverlapResponseSet,
 * @Provenance IgnoreResponseSet, AllChannelsSet, ObjectTypeSet all true. Extra: local
 * @Provenance construct all false, MeshComp null. FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay writes a block, an overlap and an ignore response, then a
	 * blanket all-channel response, then the object type, reading each back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionResponse
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return all six flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionResponse
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all six flags are clear and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (ResponseSet)
		{
			return false;
		}
		if (AllChannelsSet)
		{
			return false;
		}
		if (ObjectTypeSet)
		{
			return false;
		}
		if (BlockResponseSet)
		{
			return false;
		}
		if (OverlapResponseSet)
		{
			return false;
		}
		if (IgnoreResponseSet)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionResponse
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionResponseActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionResponse setup: required Second is null");
		}
		ResponseSet = true;
		ObjectTypeSet = true;

		if (!ResponseSet)
		{
			return false;
		}
		if (!ObjectTypeSet)
		{
			return false;
		}
		if (Second.ResponseSet)
		{
			return false;
		}
		return !Second.ObjectTypeSet;
	}
}
