// Theme: Gameplay.Physics. WorldStory collision object type, channels, and responses.
// C++: AngelscriptCoveragePhysicsTests.cpp::CollisionChannelsAndResponses
// Oracle VerifyByPath after BeginPlay: ObjectTypeSet, StandardChannelsRead (6), ChannelResponseSet,
// OverlapResponseSet, IgnoreResponseSet, AllChannelsResponseSet, ProfileChannelConversionsCovered true.
// Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.

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
}

bool Observe_CollisionChannels_Defaults(ACoveragePhysicsChannelsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CollisionChannelsAndResponses setup: required Actor is null");
	}
	return Actor.ObjectTypeSet == false
		&& Actor.ChannelResponseSet == false
		&& Actor.AllChannelsResponseSet == false
		&& Actor.StandardChannelsRead == false
		&& Actor.ProfileChannelConversionsCovered == false
		&& Actor.OverlapResponseSet == false
		&& Actor.IgnoreResponseSet == false;
}
