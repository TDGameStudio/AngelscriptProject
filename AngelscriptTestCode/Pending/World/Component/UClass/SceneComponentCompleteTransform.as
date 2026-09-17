/**
 * @version v1
 * @summary A complete world transform set on a scene component and read back through GetComponentTransform. C++ verifies the final location, rotation and scale. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary A complete world transform set on a scene component and read back through GetComponentTransform. C++ verifies the final location, rotation and scale. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageSceneComponentCompleteTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	FVector FinalLocation;

	UPROPERTY()
	FRotator FinalRotation;

	UPROPERTY()
	FVector FinalScale;

	/**
	 * WorldStory: BeginPlay builds a complete transform, applies it without sweeping,
	 * then reads it back and stores the three parts.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentCompleteTransform
	 * @Inputs a default-attached USceneComponent
	 * @Return FinalLocation (100, 200, 300), FinalRotation ~(10, 20, 30), FinalScale (1.5, 1.5, 1.5)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Create and set a complete transform
		FTransform NewTransform;
		NewTransform.SetLocation(FVector(100.0f, 200.0f, 300.0f));
		NewTransform.SetRotation(FQuat(FRotator(10.0f, 20.0f, 30.0f)));
		NewTransform.SetScale3D(FVector(1.5f, 1.5f, 1.5f));

		// SetWorldTransform is a reflective K2_ bind requiring the sweep/teleport
		// arguments (FHitResult&out has no AS default).
		FHitResult SweepHit;
		Root.SetWorldTransform(NewTransform, false, SweepHit, false);

		// Read back using GetComponentTransform
		FTransform CurrentTransform = Root.GetComponentTransform();
		FinalLocation = CurrentTransform.GetLocation();
		FinalRotation = CurrentTransform.GetRotation().Rotator();
		FinalScale = CurrentTransform.GetScale3D();
	}

	/**
	 * Observe that a locally constructed actor holds no transform and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentCompleteTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when location, rotation and scale are zero and Root is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FinalLocation.X != 0.0f)
		{
			return false;
		}
		if (FinalRotation.Pitch != 0.0f)
		{
			return false;
		}
		if (FinalScale.X != 0.0f)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentCompleteTransform
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the transform and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentCompleteTransformActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentCompleteTransform setup: required Second is null");
		}
		FinalLocation = FVector(100.0f, 200.0f, 300.0f);
		FinalScale = FVector(1.5f, 1.5f, 1.5f);

		if (FinalLocation.X != 100.0f)
		{
			return false;
		}
		if (FinalScale.X != 1.5f)
		{
			return false;
		}
		if (Second.FinalLocation.X != 0.0f)
		{
			return false;
		}
		return Second.FinalScale.X == 0.0f;
	}
}
/** @end */
