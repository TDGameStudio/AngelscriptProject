// Theme: Gameplay.Physics. WorldStory FHitResult field accessors on a manual hit.
// C++: AngelscriptCoveragePhysicsTests.cpp::HitResultFields
// Oracle VerifyByPath after BeginPlay: HitResultFieldsAccessed, BlockingHitChecked, LocationChecked,
// NormalChecked, DistanceChecked, ActorChecked, ComponentChecked, ImpactPoint/Normal, Time, BoneName,
// PhysMaterialChecked true. ManualHit Distance 123.0, Time 0.5, BoneName CoverageBone.
// Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoveragePhysicsHitResultActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool HitResultFieldsAccessed = false;

	UPROPERTY()
	bool BlockingHitChecked = false;

	UPROPERTY()
	bool LocationChecked = false;

	UPROPERTY()
	bool NormalChecked = false;

	UPROPERTY()
	bool DistanceChecked = false;

	UPROPERTY()
	bool ActorChecked = false;

	UPROPERTY()
	bool ComponentChecked = false;

	UPROPERTY()
	bool ImpactPointChecked = false;

	UPROPERTY()
	bool ImpactNormalChecked = false;

	UPROPERTY()
	bool TimeChecked = false;

	UPROPERTY()
	bool BoneNameChecked = false;

	UPROPERTY()
	bool PhysMaterialChecked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FVector Start = GetActorLocation();
		FVector End = Start + FVector(0, 0, -1000);

		FHitResult Hit;
		FCollisionQueryParams QueryParams(n"CoverageHitResultTrace", true, this);
		FCollisionResponseParams ResponseParams(ECollisionResponse::ECR_Block);
		System::LineTraceSingleByChannel(Hit, Start, End, ECollisionChannel::ECC_Visibility, QueryParams, ResponseParams);

		// Access FHitResult fields
		FHitResult ManualHit(this, Sphere, FVector(10, 20, 30), FVector(0, 0, 1));
		ManualHit.SetbBlockingHit(true);
		ManualHit.SetActor(this);
		ManualHit.SetComponent(Sphere);
		ManualHit.Distance = 123.0f;
		ManualHit.Time = 0.5f;
		ManualHit.ImpactPoint = FVector(11, 22, 33);
		ManualHit.ImpactNormal = FVector(0, 1, 0);
		ManualHit.BoneName = n"CoverageBone";
		ManualHit.SetPhysMaterial(nullptr);

		BlockingHitChecked = ManualHit.GetbBlockingHit();
		ActorChecked = (ManualHit.GetActor() == this);
		ComponentChecked = (ManualHit.GetComponent() == Sphere);

		LocationChecked = ManualHit.Location.Equals(FVector(10, 20, 30), 0.01f);
		NormalChecked = ManualHit.Normal.Equals(FVector(0, 0, 1), 0.01f);

		DistanceChecked = (ManualHit.Distance > 122.9f && ManualHit.Distance < 123.1f);
		ImpactPointChecked = ManualHit.ImpactPoint.Equals(FVector(11, 22, 33), 0.01f);
		ImpactNormalChecked = ManualHit.ImpactNormal.Equals(FVector(0, 1, 0), 0.01f);
		TimeChecked = (ManualHit.Time > 0.49f && ManualHit.Time < 0.51f);
		BoneNameChecked = (ManualHit.BoneName == n"CoverageBone");
		PhysMaterialChecked = (ManualHit.GetPhysMaterial() == nullptr);

		FVector ImpactPt = Hit.ImpactPoint;
		FVector ImpactNorm = Hit.ImpactNormal;
		float Time = Hit.Time;
		FName BoneName = Hit.BoneName;

		HitResultFieldsAccessed = true;
	}
}

bool Observe_HitResultFields_Defaults(ACoveragePhysicsHitResultActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HitResultFields setup: required Actor is null");
	}
	return Actor.HitResultFieldsAccessed == false
		&& Actor.BlockingHitChecked == false
		&& Actor.LocationChecked == false
		&& Actor.NormalChecked == false
		&& Actor.DistanceChecked == false
		&& Actor.ActorChecked == false
		&& Actor.ComponentChecked == false
		&& Actor.ImpactPointChecked == false
		&& Actor.ImpactNormalChecked == false
		&& Actor.TimeChecked == false
		&& Actor.BoneNameChecked == false
		&& Actor.PhysMaterialChecked == false;
}

bool Observe_HitResultFields_EmptyHitBoundary()
{
	FHitResult Hit;
	return Hit.GetbBlockingHit() == false && Hit.GetPhysMaterial() == nullptr;
}
