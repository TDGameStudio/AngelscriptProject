/**
 * @version v1
 * @summary Collision-enabled modes and named collision profiles, plus component query settings. C++ verifies the four flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Collision-enabled modes and named collision profiles, plus component query settings. C++ verifies the four flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
UCLASS()
class ACoveragePhysicsCollisionProfilesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool CollisionEnabledModesRoundTripped = false;

	UPROPERTY()
	bool CoreProfilesRoundTripped = false;

	UPROPERTY()
	bool PawnProfilesRoundTripped = false;

	UPROPERTY()
	bool ComponentQuerySettingsRoundTripped = false;

	/**
	 * WorldStory: BeginPlay walks every collision-enabled mode, the core and pawn
	 * profiles, then object type, responses and overlap generation.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.CollisionProfilesAndEnabledModes
	 * @Inputs a default-attached USphereComponent
	 * @Return CollisionEnabledModesRoundTripped, CoreProfilesRoundTripped,
	 * PawnProfilesRoundTripped and ComponentQuerySettingsRoundTripped true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		bool bNoCollision = Sphere.GetCollisionEnabled() == ECollisionEnabled::NoCollision;
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		bool bQueryOnly = Sphere.GetCollisionEnabled() == ECollisionEnabled::QueryOnly;
		Sphere.SetCollisionEnabled(ECollisionEnabled::PhysicsOnly);
		bool bPhysicsOnly = Sphere.GetCollisionEnabled() == ECollisionEnabled::PhysicsOnly;
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		bool bQueryAndPhysics = Sphere.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics;
		CollisionEnabledModesRoundTripped = bNoCollision && bQueryOnly && bPhysicsOnly && bQueryAndPhysics;

		Sphere.SetCollisionProfileName(n"NoCollision");
		bool bNoCollisionProfile = Sphere.GetCollisionProfileName() == n"NoCollision";
		Sphere.SetCollisionProfileName(n"BlockAll");
		bool bBlockAllProfile = Sphere.GetCollisionProfileName() == n"BlockAll";
		Sphere.SetCollisionProfileName(n"OverlapAll");
		bool bOverlapAllProfile = Sphere.GetCollisionProfileName() == n"OverlapAll";
		Sphere.SetCollisionProfileName(n"BlockAllDynamic");
		bool bBlockAllDynamicProfile = Sphere.GetCollisionProfileName() == n"BlockAllDynamic";
		Sphere.SetCollisionProfileName(n"OverlapAllDynamic");
		bool bOverlapAllDynamicProfile = Sphere.GetCollisionProfileName() == n"OverlapAllDynamic";
		Sphere.SetCollisionProfileName(n"PhysicsActor");
		bool bPhysicsActorProfile = Sphere.GetCollisionProfileName() == n"PhysicsActor";
		CoreProfilesRoundTripped =
			bNoCollisionProfile
			&& bBlockAllProfile
			&& bOverlapAllProfile
			&& bBlockAllDynamicProfile
			&& bOverlapAllDynamicProfile
			&& bPhysicsActorProfile;

		Sphere.SetCollisionProfileName(n"IgnoreOnlyPawn");
		bool bIgnoreOnlyPawnProfile = Sphere.GetCollisionProfileName() == n"IgnoreOnlyPawn";
		Sphere.SetCollisionProfileName(n"OverlapOnlyPawn");
		bool bOverlapOnlyPawnProfile = Sphere.GetCollisionProfileName() == n"OverlapOnlyPawn";
		Sphere.SetCollisionProfileName(n"Pawn");
		bool bPawnProfile = Sphere.GetCollisionProfileName() == n"Pawn";
		PawnProfilesRoundTripped = bIgnoreOnlyPawnProfile && bOverlapOnlyPawnProfile && bPawnProfile;

		Sphere.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		Sphere.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
		Sphere.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Overlap);
		Sphere.SetGenerateOverlapEvents(true);
		Sphere.SetNotifyRigidBodyCollision(true);

		ComponentQuerySettingsRoundTripped =
			Sphere.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic
			&& Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Overlap
			&& Sphere.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Ignore
			&& Sphere.GetGenerateOverlapEvents();
	}

	/**
	 * Observe that a locally constructed actor holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionProfilesAndEnabledModes
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when CollisionEnabledModesRoundTripped, CoreProfilesRoundTripped,
	 * PawnProfilesRoundTripped and ComponentQuerySettingsRoundTripped are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (CollisionEnabledModesRoundTripped)
		{
			return false;
		}
		if (CoreProfilesRoundTripped)
		{
			return false;
		}
		if (PawnProfilesRoundTripped)
		{
			return false;
		}
		return ComponentQuerySettingsRoundTripped == false;
	}
}
/** @end */
