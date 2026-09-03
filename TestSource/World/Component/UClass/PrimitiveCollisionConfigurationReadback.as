/**
 * Collision enabled state, object type and channel response all read back off a
 * sphere component. C++ verifies the three flags by path. The observers cover the
 * local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.PrimitiveCollisionConfigurationReadback
 * @Harness UClass
 * @Tag World.Component.PrimitiveCollisionConfigurationReadback
 * @Provenance Theme: World.Component. WorldStory: collision enabled/object type/channel
 * @Provenance response round-trip.
 * @Provenance C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveCollisionConfigurationReadback
 * @Provenance sha256=620b625538544501271301d006f08424857381281d805c056b1b5440ffa6c90a; lines 292-334.
 * @Provenance Oracle VerifyByPath CollisionEnabledRoundTripped, ObjectTypeRoundTripped,
 * @Provenance ChannelResponseRoundTripped true. Extra: local construct flags false,
 * @Provenance SphereComp null. FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay walks every collision-enabled state, both object types
	 * and all three channel responses, reading each back after it is written.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveCollisionConfigurationReadback
	 * @Inputs a default-attached USphereComponent
	 * @Return all three flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionConfigurationReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (CollisionEnabledRoundTripped)
		{
			return false;
		}
		if (ObjectTypeRoundTripped)
		{
			return false;
		}
		if (ChannelResponseRoundTripped)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveCollisionConfigurationReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveCollisionConfigurationReadbackActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveCollisionConfigurationReadback setup: required Second is null");
		}
		CollisionEnabledRoundTripped = true;

		if (!CollisionEnabledRoundTripped)
		{
			return false;
		}
		return !Second.CollisionEnabledRoundTripped;
	}
}
