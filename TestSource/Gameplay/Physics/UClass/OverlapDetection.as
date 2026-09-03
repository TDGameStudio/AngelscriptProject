/**
 * OverlapMultiByChannel with sphere, box and capsule shapes. C++ verifies the three
 * executed flags by path after BeginPlay, so those UPROPERTY names are part of the
 * contract and are kept verbatim. The observer covers the local-construct defaults.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.OverlapDetection
 * @Harness UClass
 * @Tag Gameplay.Physics.OverlapDetection
 * @Provenance Theme: Gameplay.Physics. WorldStory OverlapMultiByChannel sphere/box/capsule.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::OverlapDetection
 * @Provenance Oracle VerifyByPath after BeginPlay: Sphere/Box/Capsule OverlapByChannelExecuted true.
 * @Provenance Extra: defaults false / SphereOverlapCount 0. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoveragePhysicsOverlapActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool SphereOverlapByChannelExecuted = false;

	UPROPERTY()
	bool BoxOverlapByChannelExecuted = false;

	UPROPERTY()
	bool CapsuleOverlapByChannelExecuted = false;

	UPROPERTY()
	int SphereOverlapCount = 0;

	/**
	 * WorldStory: BeginPlay runs OverlapMultiByChannel with a sphere, a box and a
	 * capsule at the actor location.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.OverlapDetection
	 * @Inputs a default-attached USphereComponent
	 * @Return SphereOverlapByChannelExecuted, BoxOverlapByChannelExecuted and
	 * CapsuleOverlapByChannelExecuted true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FVector Location = GetActorLocation();
		FCollisionQueryParams QueryParams(n"CoverageOverlapParams", false, this);
		FCollisionResponseParams ResponseParams(ECollisionResponse::ECR_Overlap);

		TArray<FOverlapResult> OutOverlaps;
		System::OverlapMultiByChannel(
			OutOverlaps, Location, FQuat::Identity, ECollisionChannel::ECC_WorldDynamic,
			FCollisionShape::MakeSphere(500.0f), QueryParams, ResponseParams);
		SphereOverlapByChannelExecuted = true;
		SphereOverlapCount = OutOverlaps.Num();

		System::OverlapMultiByChannel(
			OutOverlaps, Location, FQuat::Identity, ECollisionChannel::ECC_WorldDynamic,
			FCollisionShape::MakeBox(FVector(100, 100, 100)), QueryParams, ResponseParams);
		BoxOverlapByChannelExecuted = true;

		System::OverlapMultiByChannel(
			OutOverlaps, Location, FQuat::Identity, ECollisionChannel::ECC_WorldDynamic,
			FCollisionShape::MakeCapsule(50.0f, 100.0f), QueryParams, ResponseParams);
		CapsuleOverlapByChannelExecuted = true;
	}

	/**
	 * Observe that a locally constructed actor holds every flag false and count 0.
	 *
	 * @Kind Observe
	 * @Covers Physics.OverlapDetection
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when SphereOverlapByChannelExecuted, BoxOverlapByChannelExecuted and
	 * CapsuleOverlapByChannelExecuted are false and SphereOverlapCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (SphereOverlapByChannelExecuted)
		{
			return false;
		}
		if (BoxOverlapByChannelExecuted)
		{
			return false;
		}
		if (CapsuleOverlapByChannelExecuted)
		{
			return false;
		}
		return SphereOverlapCount == 0;
	}
}
