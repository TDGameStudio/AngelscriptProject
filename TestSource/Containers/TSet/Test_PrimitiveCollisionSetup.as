// Theme: Containers.TSet. WorldStory: primitive collision enable, profile, overlap, notify.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionSetup
// CompileScriptModule + spawn + BeginPlay. Oracle: CollisionEnabledSet, ProfileSet,
// GenerateOverlapEventsSet, CollisionModesCovered, CommonProfilesCovered,
// NotifyRigidBodyCollisionSet all true.
// Extra: local construct leaves flags false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoveragePrimitiveCollisionSetupActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool CollisionEnabledSet = false;

	UPROPERTY()
	bool ProfileSet = false;

	UPROPERTY()
	bool GenerateOverlapEventsSet = false;

	UPROPERTY()
	bool CollisionModesCovered = false;

	UPROPERTY()
	bool CommonProfilesCovered = false;

	UPROPERTY()
	bool NotifyRigidBodyCollisionSet = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set collision enabled
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		CollisionEnabledSet = (MeshComp.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics);

		// Set collision profile
		MeshComp.SetCollisionProfileName(n"BlockAll");
		ProfileSet = (MeshComp.GetCollisionProfileName() == n"BlockAll");

		// Enable overlap events
		MeshComp.SetGenerateOverlapEvents(true);
		GenerateOverlapEventsSet = MeshComp.GetGenerateOverlapEvents();

		// Exercise collision enabled modes with readback.
		MeshComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		bool bNoCollision = MeshComp.GetCollisionEnabled() == ECollisionEnabled::NoCollision;
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		bool bQueryOnly = MeshComp.GetCollisionEnabled() == ECollisionEnabled::QueryOnly;
		MeshComp.SetCollisionEnabled(ECollisionEnabled::PhysicsOnly);
		bool bPhysicsOnly = MeshComp.GetCollisionEnabled() == ECollisionEnabled::PhysicsOnly;
		MeshComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		bool bQueryAndPhysics = MeshComp.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics;
		CollisionModesCovered = bNoCollision && bQueryOnly && bPhysicsOnly && bQueryAndPhysics;

		// Exercise common built-in profiles with readback.
		MeshComp.SetCollisionProfileName(n"NoCollision");
		bool bNoCollisionProfile = MeshComp.GetCollisionProfileName() == n"NoCollision";
		MeshComp.SetCollisionProfileName(n"BlockAll");
		bool bBlockAllProfile = MeshComp.GetCollisionProfileName() == n"BlockAll";
		MeshComp.SetCollisionProfileName(n"OverlapAll");
		bool bOverlapAllProfile = MeshComp.GetCollisionProfileName() == n"OverlapAll";
		MeshComp.SetCollisionProfileName(n"BlockAllDynamic");
		bool bBlockAllDynamicProfile = MeshComp.GetCollisionProfileName() == n"BlockAllDynamic";
		MeshComp.SetCollisionProfileName(n"OverlapAllDynamic");
		bool bOverlapAllDynamicProfile = MeshComp.GetCollisionProfileName() == n"OverlapAllDynamic";
		MeshComp.SetCollisionProfileName(n"IgnoreOnlyPawn");
		bool bIgnoreOnlyPawnProfile = MeshComp.GetCollisionProfileName() == n"IgnoreOnlyPawn";
		MeshComp.SetCollisionProfileName(n"OverlapOnlyPawn");
		bool bOverlapOnlyPawnProfile = MeshComp.GetCollisionProfileName() == n"OverlapOnlyPawn";
		MeshComp.SetCollisionProfileName(n"Pawn");
		bool bPawnProfile = MeshComp.GetCollisionProfileName() == n"Pawn";
		MeshComp.SetCollisionProfileName(n"PhysicsActor");
		bool bPhysicsActorProfile = MeshComp.GetCollisionProfileName() == n"PhysicsActor";
		CommonProfilesCovered =
			bNoCollisionProfile
			&& bBlockAllProfile
			&& bOverlapAllProfile
			&& bBlockAllDynamicProfile
			&& bOverlapAllDynamicProfile
			&& bIgnoreOnlyPawnProfile
			&& bOverlapOnlyPawnProfile
			&& bPawnProfile
			&& bPhysicsActorProfile;

		MeshComp.SetNotifyRigidBodyCollision(true);
		NotifyRigidBodyCollisionSet = true;
	}
}

bool Observe_PrimitiveCollision_DefaultEmpty(ACoveragePrimitiveCollisionSetupActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveCollisionSetup setup: required Actor is null");
	}
	return Actor.CollisionEnabledSet == false
		&& Actor.ProfileSet == false
		&& Actor.GenerateOverlapEventsSet == false
		&& Actor.CollisionModesCovered == false
		&& Actor.CommonProfilesCovered == false
		&& Actor.NotifyRigidBodyCollisionSet == false;
}

bool Observe_PrimitiveCollision_CopyIndependence(ACoveragePrimitiveCollisionSetupActor First, ACoveragePrimitiveCollisionSetupActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveCollisionSetup setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveCollisionSetup setup: required Second is null");
	}
	First.NotifyRigidBodyCollisionSet = true;
	return First.NotifyRigidBodyCollisionSet == true && Second.NotifyRigidBodyCollisionSet == false;
}
