// Theme: World.Component. WorldStory: collision enabled/object type/channel
// response round-trip.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionConfigurationReadback
// sha256=620b625538544501271301d006f08424857381281d805c056b1b5440ffa6c90a; lines 292-334.
// Oracle VerifyByPath CollisionEnabledRoundTripped, ObjectTypeRoundTripped,
// ChannelResponseRoundTripped true. Extra: local construct flags false,
// SphereComp null. FixtureIsolated.

UCLASS()
class ACoveragePrimitiveCollisionConfigurationReadbackActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool CollisionEnabledRoundTripped = false;

	UPROPERTY()
	bool ObjectTypeRoundTripped = false;

	UPROPERTY()
	bool ChannelResponseRoundTripped = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::NoCollision);
		bool bNoCollision = SphereComp.GetCollisionEnabled() == ECollisionEnabled::NoCollision;
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		bool bQueryOnly = SphereComp.GetCollisionEnabled() == ECollisionEnabled::QueryOnly;
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		bool bQueryAndPhysics = SphereComp.GetCollisionEnabled() == ECollisionEnabled::QueryAndPhysics;
		CollisionEnabledRoundTripped = bNoCollision && bQueryOnly && bQueryAndPhysics;

		SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_WorldDynamic);
		bool bWorldDynamic = SphereComp.GetCollisionObjectType() == ECollisionChannel::ECC_WorldDynamic;
		SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_Pawn);
		bool bPawn = SphereComp.GetCollisionObjectType() == ECollisionChannel::ECC_Pawn;
		ObjectTypeRoundTripped = bWorldDynamic && bPawn;

		SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Block);
		bool bPawnBlocks = SphereComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block;
		SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Overlap);
		bool bVisibilityOverlaps = SphereComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Overlap;
		SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Ignore);
		bool bCameraIgnores = SphereComp.GetCollisionResponseToChannel(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;
		ChannelResponseRoundTripped = bPawnBlocks && bVisibilityOverlaps && bCameraIgnores;
	}
}

bool Observe_CollisionConfigReadback_DefaultFalse(ACoveragePrimitiveCollisionConfigurationReadbackActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveCollisionConfigurationReadback setup: required Actor is null");
	}
	return !Actor.CollisionEnabledRoundTripped
		&& !Actor.ObjectTypeRoundTripped
		&& !Actor.ChannelResponseRoundTripped
		&& Actor.SphereComp == nullptr;
}

bool Observe_CollisionConfigReadback_CopyIndependence(ACoveragePrimitiveCollisionConfigurationReadbackActor First, ACoveragePrimitiveCollisionConfigurationReadbackActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveCollisionConfigurationReadback setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveCollisionConfigurationReadback setup: required Second is null");
	}
	First.CollisionEnabledRoundTripped = true;
	return First.CollisionEnabledRoundTripped && !Second.CollisionEnabledRoundTripped;
}
