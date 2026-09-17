/**
 * @version v1
 * @summary Collision object type, standard channels, profile conversions and per-channel plus all-channel responses. C++ verifies the seven flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Collision object type, standard channels, profile conversions and per-channel plus all-channel responses. C++ verifies the seven flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are.
 * @topic Baseline
 */
UCLASS()
class ACoveragePhysicsChannelsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool ObjectTypeSet = false;

	UPROPERTY()
	bool ChannelResponseSet = false;

	UPROPERTY()
	bool AllChannelsResponseSet = false;

	UPROPERTY()
	bool StandardChannelsRead = false;

	UPROPERTY()
	bool ProfileChannelConversionsCovered = false;

	UPROPERTY()
	bool OverlapResponseSet = false;

	UPROPERTY()
	bool IgnoreResponseSet = false;

	UPROPERTY()
	ECollisionResponse PawnResponse;

	/**
	 * WorldStory: BeginPlay writes the physics-body object type, reads the six standard
	 * channels, covers profile conversions, then block/overlap/ignore and all-channel
	 * responses.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.CollisionChannelsAndResponses
	 * @Inputs a default-attached USphereComponent
	 * @Return ObjectTypeSet, StandardChannelsRead, ProfileChannelConversionsCovered,
	 * ChannelResponseSet, OverlapResponseSet, IgnoreResponseSet and AllChannelsResponseSet true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set collision object type
		Sphere.SetCollisionObjectType(ECollisionChannel::ECC_PhysicsBody);
		ObjectTypeSet = (Sphere.GetCollisionObjectType() == ECollisionChannel::ECC_PhysicsBody);

		int StandardChannelCount = 0;
		StandardChannelCount += int(ECollisionChannel::ECC_WorldStatic) >= 0 ? 1 : 0;
		StandardChannelCount += int(ECollisionChannel::ECC_WorldDynamic) >= 0 ? 1 : 0;
		StandardChannelCount += int(ECollisionChannel::ECC_Pawn) >= 0 ? 1 : 0;
		StandardChannelCount += int(ECollisionChannel::ECC_Visibility) >= 0 ? 1 : 0;
		StandardChannelCount += int(ECollisionChannel::ECC_Camera) >= 0 ? 1 : 0;
		StandardChannelCount += int(ECollisionChannel::ECC_PhysicsBody) >= 0 ? 1 : 0;
		StandardChannelsRead = (StandardChannelCount == 6);

		ProfileChannelConversionsCovered =
			UCollisionProfile::ConvertToCollisionChannel(false, int(UCollisionProfile::ConvertToObjectType(ECollisionChannel::ECC_WorldStatic))) == ECollisionChannel::ECC_WorldStatic
			&& UCollisionProfile::ConvertToCollisionChannel(false, int(UCollisionProfile::ConvertToObjectType(ECollisionChannel::ECC_WorldDynamic))) == ECollisionChannel::ECC_WorldDynamic
			&& UCollisionProfile::ConvertToCollisionChannel(true, int(UCollisionProfile::ConvertToTraceType(ECollisionChannel::ECC_Visibility))) == ECollisionChannel::ECC_Visibility
			&& UCollisionProfile::ConvertToCollisionChannel(true, int(UCollisionProfile::ConvertToTraceType(ECollisionChannel::ECC_Camera))) == ECollisionChannel::ECC_Camera;

		// Set response to specific channel
		Sphere.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Block);
		PawnResponse = Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn);
		ChannelResponseSet = (PawnResponse == ECollisionResponse::ECR_Block);

		Sphere.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Overlap);
		OverlapResponseSet =
			Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Overlap;

		Sphere.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		IgnoreResponseSet =
			Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;

		// Set response to all channels
		Sphere.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Block);
		AllChannelsResponseSet =
			Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block
			&& Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block
			&& Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Block;
	}

	/**
	 * Observe that a locally constructed actor holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionChannelsAndResponses
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when ObjectTypeSet, ChannelResponseSet, AllChannelsResponseSet,
	 * StandardChannelsRead, ProfileChannelConversionsCovered, OverlapResponseSet and
	 * IgnoreResponseSet are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (ObjectTypeSet)
		{
			return false;
		}
		if (ChannelResponseSet)
		{
			return false;
		}
		if (AllChannelsResponseSet)
		{
			return false;
		}
		if (StandardChannelsRead)
		{
			return false;
		}
		if (ProfileChannelConversionsCovered)
		{
			return false;
		}
		if (OverlapResponseSet)
		{
			return false;
		}
		return IgnoreResponseSet == false;
	}
}
/** @end */
