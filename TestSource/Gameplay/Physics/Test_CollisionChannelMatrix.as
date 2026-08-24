// Theme: Gameplay.Physics. WorldStory remaining built-in and game trace channels.
// C++: AngelscriptCoveragePhysicsTests.cpp::CollisionChannelMatrix
// Oracle VerifyByPath after BeginPlay: RemainingBuiltInChannelsRead true (Vehicle+Destructible == 2),
// GameTraceChannelsRead true (18), ObjectQueryParamsAcceptGameTraceChannel true.
// Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoveragePhysicsChannelMatrixActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool RemainingBuiltInChannelsRead = false;

	UPROPERTY()
	bool GameTraceChannelsRead = false;

	UPROPERTY()
	bool ObjectQueryParamsAcceptGameTraceChannel = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int BuiltInChannelCount = 0;
		BuiltInChannelCount += int(ECollisionChannel::ECC_Vehicle) >= 0 ? 1 : 0;
		BuiltInChannelCount += int(ECollisionChannel::ECC_Destructible) >= 0 ? 1 : 0;
		RemainingBuiltInChannelsRead = (BuiltInChannelCount == 2);

		int GameChannelCount = 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel1) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel2) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel3) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel4) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel5) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel6) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel7) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel8) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel9) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel10) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel11) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel12) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel13) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel14) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel15) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel16) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel17) > 0 ? 1 : 0;
		GameChannelCount += int(ECollisionChannel::ECC_GameTraceChannel18) > 0 ? 1 : 0;
		GameTraceChannelsRead = (GameChannelCount == 18);

		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_GameTraceChannel1);
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_GameTraceChannel18);
		ObjectQueryParamsAcceptGameTraceChannel = ObjectQueryParams.IsValid();
	}
}

bool Observe_ChannelMatrix_Defaults(ACoveragePhysicsChannelMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CollisionChannelMatrix setup: required Actor is null");
	}
	return Actor.RemainingBuiltInChannelsRead == false
		&& Actor.GameTraceChannelsRead == false
		&& Actor.ObjectQueryParamsAcceptGameTraceChannel == false;
}

bool Observe_ChannelMatrix_EmptyObjectQueryBoundary()
{
	FCollisionObjectQueryParams ObjectQueryParams;
	return ObjectQueryParams.IsValid() == false;
}
