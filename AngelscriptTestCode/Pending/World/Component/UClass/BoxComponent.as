/**
 * @version v1
 * @summary An actor whose UBoxComponent BeginPlay records the extent before and after SetBoxExtent. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary An actor whose UBoxComponent BeginPlay records the extent before and after SetBoxExtent. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageSpecialBoxActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBoxComponent BoxComp;

	UPROPERTY()
	FVector InitialExtent;

	UPROPERTY()
	FVector NewExtent;

	/**
	 * WorldStory: BeginPlay reads the unscaled extent, resizes the box, then reads
	 * it again.
	 *
	 * @Kind WorldStory
	 * @Covers Component.BoxComponent
	 * @Inputs a default-attached UBoxComponent
	 * @Return NewExtent == (100, 200, 300) after SetBoxExtent
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialExtent = BoxComp.GetUnscaledBoxExtent();

		BoxComp.SetBoxExtent(FVector(100.0f, 200.0f, 300.0f));

		NewExtent = BoxComp.GetUnscaledBoxExtent();
	}

	/**
	 * Observe that a locally constructed actor has no extents and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.BoxComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both extents are empty and BoxComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialExtent.X != 0.0f)
		{
			return false;
		}
		if (NewExtent.X != 0.0f)
		{
			return false;
		}
		if (NewExtent.Y != 0.0f)
		{
			return false;
		}
		if (NewExtent.Z != 0.0f)
		{
			return false;
		}
		return BoxComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.BoxComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the new extent and the other stays empty
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialBoxActor Second)
	{
		if (Second is null)
		{
			throw("BoxComponent setup: required Second is null");
		}
		NewExtent = FVector(100.0f, 200.0f, 300.0f);

		if (NewExtent.X != 100.0f)
		{
			return false;
		}
		if (NewExtent.Z != 300.0f)
		{
			return false;
		}
		if (Second.NewExtent.X != 0.0f)
		{
			return false;
		}
		return Second.NewExtent.Z == 0.0f;
	}
}
/** @end */
