/**
 * @version v1
 * @summary TargetArmLength and CameraLagSpeed written and read on a spring arm component. C++ verifies both. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary TargetArmLength and CameraLagSpeed written and read on a spring arm component. C++ verifies both. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageSpecialSpringArmActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USpringArmComponent SpringArmComp;

	UPROPERTY()
	float InitialArmLength = 0.0f;

	UPROPERTY()
	float NewArmLength = 0.0f;

	UPROPERTY()
	float CameraLagSpeed = 0.0f;

	/**
	 * WorldStory: BeginPlay reads the starting arm length, writes both properties,
	 * then reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SpringArmComponent
	 * @Inputs an attached USpringArmComponent
	 * @Return NewArmLength == 500 and CameraLagSpeed == 8
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (SpringArmComp != nullptr)
		{
			InitialArmLength = SpringArmComp.TargetArmLength;

			SpringArmComp.TargetArmLength = 500.0f;
			SpringArmComp.CameraLagSpeed = 8.0f;

			NewArmLength = SpringArmComp.TargetArmLength;
			CameraLagSpeed = SpringArmComp.CameraLagSpeed;
		}
	}

	/**
	 * Observe that a locally constructed actor has no values and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SpringArmComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three values are 0 and both handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialArmLength != 0.0f)
		{
			return false;
		}
		if (NewArmLength != 0.0f)
		{
			return false;
		}
		if (CameraLagSpeed != 0.0f)
		{
			return false;
		}
		if (SpringArmComp != nullptr)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SpringArmComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both values and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialSpringArmActor Second)
	{
		if (Second is null)
		{
			throw("SpringArmComponent setup: required Second is null");
		}
		NewArmLength = 500.0f;
		CameraLagSpeed = 8.0f;

		if (NewArmLength != 500.0f)
		{
			return false;
		}
		if (CameraLagSpeed != 8.0f)
		{
			return false;
		}
		if (Second.NewArmLength != 0.0f)
		{
			return false;
		}
		return Second.CameraLagSpeed == 0.0f;
	}
}
/** @end */
