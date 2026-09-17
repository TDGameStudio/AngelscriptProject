/**
 * @version v1
 * @summary World location, rotation and scale set with explicit sweep arguments, then read back. SetWorldLocation and SetWorldRotation are reflective K2_ binds whose FHitResult&out sweep parameter has no script default, so all four.
 * @topic World
 */
/**
 * @version root
 * @summary World location, rotation and scale set with explicit sweep arguments, then read back. SetWorldLocation and SetWorldRotation are reflective K2_ binds whose FHitResult&out sweep parameter has no script default, so all four.
 * @topic Baseline
 */
UCLASS()
class ACoverageSceneComponentWorldTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY()
	FVector InitialLocation;

	UPROPERTY()
	FVector NewLocation;

	UPROPERTY()
	FRotator NewRotation;

	UPROPERTY()
	FVector NewScale;

	/**
	 * WorldStory: BeginPlay reads the starting location, writes all three world
	 * transform parts, then reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentWorldTransform
	 * @Inputs a default-attached USceneComponent
	 * @Return NewLocation (100, 200, 300), NewRotation (0, 90, 0), NewScale (2, 2, 2)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialLocation = Root.GetWorldLocation();

		// Set world transform. SetWorldLocation/SetWorldRotation are reflective
		// K2_ binds with a required FHitResult&out sweep param (no AS defaults on
		// out params), so all four arguments must be supplied explicitly.
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 200.0f, 300.0f), false, SweepHit, false);
		Root.SetWorldRotation(FRotator(0.0f, 90.0f, 0.0f), false, SweepHit, false);
		Root.SetWorldScale3D(FVector(2.0f, 2.0f, 2.0f));

		// Read back
		NewLocation = Root.GetWorldLocation();
		NewRotation = Root.GetWorldRotation();
		// No direct world-scale getter is AS-bound; derive it from the world transform.
		NewScale = Root.GetComponentTransform().GetScale3D();
	}

	/**
	 * Observe that a locally constructed actor holds no transform and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentWorldTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when location, rotation and scale are all zero and Root is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (NewLocation.X != 0.0f)
		{
			return false;
		}
		if (NewLocation.Y != 0.0f)
		{
			return false;
		}
		if (NewLocation.Z != 0.0f)
		{
			return false;
		}
		if (NewRotation.Yaw != 0.0f)
		{
			return false;
		}
		if (NewScale.X != 0.0f)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentWorldTransform
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the new location and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentWorldTransformActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentWorldTransform setup: required Second is null");
		}
		NewLocation = FVector(100.0f, 200.0f, 300.0f);

		if (NewLocation.X != 100.0f)
		{
			return false;
		}
		if (Second.NewLocation.X != 0.0f)
		{
			return false;
		}
		return Second.NewScale.X == 0.0f;
	}
}
/** @end */
