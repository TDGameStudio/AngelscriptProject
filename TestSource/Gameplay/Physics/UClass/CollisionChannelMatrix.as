/**
 * Remaining built-in and game trace channels, plus object-query acceptance of a
 * game trace channel. C++ verifies the three flags by path after BeginPlay, so those
 * UPROPERTY names are part of the contract and are kept verbatim. The observers cover
 * the local-construct defaults and an empty object-query boundary.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.CollisionChannelMatrix
 * @Harness UClass
 * @Tag Gameplay.Physics.CollisionChannelMatrix
 * @Provenance Theme: Gameplay.Physics. WorldStory remaining built-in and game trace channels.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::CollisionChannelMatrix
 * @Provenance Oracle VerifyByPath after BeginPlay: RemainingBuiltInChannelsRead true (Vehicle+Destructible == 2),
 * @Provenance GameTraceChannelsRead true (18), ObjectQueryParamsAcceptGameTraceChannel true.
 * @Provenance Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.
 */

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

	/**
	 * WorldStory: BeginPlay counts remaining built-in channels and game trace channels,
	 * then accepts two game channels on an object-query params value.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.CollisionChannelMatrix
	 * @Inputs a default-attached USphereComponent
	 * @Return RemainingBuiltInChannelsRead, GameTraceChannelsRead and
	 * ObjectQueryParamsAcceptGameTraceChannel true
	 */
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

	/**
	 * Observe that a locally constructed actor holds all three flags false.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionChannelMatrix
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when RemainingBuiltInChannelsRead, GameTraceChannelsRead and
	 * ObjectQueryParamsAcceptGameTraceChannel are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (RemainingBuiltInChannelsRead)
		{
			return false;
		}
		if (GameTraceChannelsRead)
		{
			return false;
		}
		return ObjectQueryParamsAcceptGameTraceChannel == false;
	}

	/**
	 * Observe that a default object-query params value is invalid.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionChannelMatrix
	 * @Inputs a default-constructed FCollisionObjectQueryParams
	 * @Return true when IsValid is false
	 * @Boundary empty object query
	 */
	UFUNCTION()
	bool EmptyObjectQueryBoundary()
	{
		FCollisionObjectQueryParams ObjectQueryParams;
		return ObjectQueryParams.IsValid() == false;
	}
}
