// Theme: Gameplay.Physics. WorldStory OverlapMultiByChannel sphere/box/capsule.
// C++: AngelscriptCoveragePhysicsTests.cpp::OverlapDetection
// Oracle VerifyByPath after BeginPlay: Sphere/Box/Capsule OverlapByChannelExecuted true.
// Extra: defaults false / SphereOverlapCount 0. FixtureIsolated. Keep UPROPERTY names.

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
}

bool Observe_OverlapDetection_Defaults(ACoveragePhysicsOverlapActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OverlapDetection setup: required Actor is null");
	}
	return Actor.SphereOverlapByChannelExecuted == false
		&& Actor.BoxOverlapByChannelExecuted == false
		&& Actor.CapsuleOverlapByChannelExecuted == false
		&& Actor.SphereOverlapCount == 0;
}
