/**
 * @version v1
 * @summary A child component's relative location and rotation versus the world location it resolves to. C++ verifies all three. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary A child component's relative location and rotation versus the world location it resolves to. C++ verifies all three. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageSceneComponentRelativeTransformActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;

	UPROPERTY()
	FVector ChildRelativeLocation;

	UPROPERTY()
	FRotator ChildRelativeRotation;

	UPROPERTY()
	FVector ChildWorldLocation;

	/**
	 * WorldStory: BeginPlay moves the root to a known position, sets the child's
	 * relative transform, then reads both back along with the resolved world
	 * location.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentRelativeTransform
	 * @Inputs a root and an attached child scene component
	 * @Return ChildRelativeLocation (50, 0, 0), ChildRelativeRotation yaw 45, ChildWorldLocation (150, 0, 0)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set root to known position
		FHitResult SweepHit;
		Root.SetWorldLocation(FVector(100.0f, 0.0f, 0.0f), false, SweepHit, false);

		// Set child relative transform
		Child.SetRelativeLocation(FVector(50.0f, 0.0f, 0.0f));
		Child.SetRelativeRotation(FRotator(0.0f, 45.0f, 0.0f));

		// Read back
		ChildRelativeLocation = Child.RelativeLocation;
		ChildRelativeRotation = Child.RelativeRotation;
		ChildWorldLocation = Child.GetWorldLocation();
	}

	/**
	 * Observe that a locally constructed actor holds no transform and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentRelativeTransform
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three transforms are zero and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ChildRelativeLocation.X != 0.0f)
		{
			return false;
		}
		if (ChildRelativeRotation.Yaw != 0.0f)
		{
			return false;
		}
		if (ChildWorldLocation.X != 0.0f)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentRelativeTransform
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the relative location and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentRelativeTransformActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentRelativeTransform setup: required Second is null");
		}
		ChildRelativeLocation = FVector(50.0f, 0.0f, 0.0f);

		if (ChildRelativeLocation.X != 50.0f)
		{
			return false;
		}
		return Second.ChildRelativeLocation.X == 0.0f;
	}
}
/** @end */
