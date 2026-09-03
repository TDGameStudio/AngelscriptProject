/**
 * FHitResult field accessors on a manually constructed hit, plus a visibility line
 * trace. C++ verifies the twelve flags by path after BeginPlay, so those UPROPERTY
 * names are part of the contract and are kept verbatim. The observers cover the
 * local-construct defaults and an empty hit.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.HitResultFields
 * @Harness UClass
 * @Tag Gameplay.Physics.HitResultFields
 * @Provenance Theme: Gameplay.Physics. WorldStory FHitResult field accessors on a manual hit.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::HitResultFields
 * @Provenance Oracle VerifyByPath after BeginPlay: HitResultFieldsAccessed, BlockingHitChecked, LocationChecked,
 * @Provenance NormalChecked, DistanceChecked, ActorChecked, ComponentChecked, ImpactPoint/Normal, Time, BoneName,
 * @Provenance PhysMaterialChecked true. ManualHit Distance 123.0, Time 0.5, BoneName CoverageBone.
 * @Provenance Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.
 */

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

	/**
	 * WorldStory: BeginPlay traces visibility, then writes a manual hit and reads
	 * blocking, actor, component, location, normal, distance, impact, time, bone
	 * and phys-material fields.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.HitResultFields
	 * @Inputs a default-attached USphereComponent
	 * @Return all twelve flags true; ManualHit Distance 123.0, Time 0.5, BoneName CoverageBone
	 */
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

	/**
	 * Observe that a locally constructed actor holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.HitResultFields
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when HitResultFieldsAccessed, BlockingHitChecked, LocationChecked,
	 * NormalChecked, DistanceChecked, ActorChecked, ComponentChecked, ImpactPointChecked,
	 * ImpactNormalChecked, TimeChecked, BoneNameChecked and PhysMaterialChecked are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (HitResultFieldsAccessed)
		{
			return false;
		}
		if (BlockingHitChecked)
		{
			return false;
		}
		if (LocationChecked)
		{
			return false;
		}
		if (NormalChecked)
		{
			return false;
		}
		if (DistanceChecked)
		{
			return false;
		}
		if (ActorChecked)
		{
			return false;
		}
		if (ComponentChecked)
		{
			return false;
		}
		if (ImpactPointChecked)
		{
			return false;
		}
		if (ImpactNormalChecked)
		{
			return false;
		}
		if (TimeChecked)
		{
			return false;
		}
		if (BoneNameChecked)
		{
			return false;
		}
		return PhysMaterialChecked == false;
	}

	/**
	 * Observe that a default hit result is not blocking and has a null phys material.
	 *
	 * @Kind Observe
	 * @Covers Physics.HitResultFields
	 * @Inputs a default-constructed hit result
	 * @Return true when GetbBlockingHit is false and GetPhysMaterial is null
	 * @Boundary empty hit
	 */
	UFUNCTION()
	bool EmptyHitBoundary()
	{
		FHitResult Hit;

		if (Hit.GetbBlockingHit())
		{
			return false;
		}
		return Hit.GetPhysMaterial() == nullptr;
	}
}
