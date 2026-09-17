/**
 * @version v1
 * @summary Collision enabled state, object type and channel response all read back off a sphere component. C++ verifies the three flags by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary Collision enabled state, object type and channel response all read back off a sphere component. C++ verifies the three flags by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
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
/** @end */
