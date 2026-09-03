/**
 * An actor whose UCameraComponent BeginPlay writes and reads FieldOfView. The
 * observers cover the local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.CameraComponent
 * @Harness UClass
 * @Tag World.Component.CameraComponent
 * @Provenance Theme: World.Component. WorldStory: CameraComp.FieldOfView write/read.
 * @Provenance C++: AngelscriptCoverageSpecialComponentTests.cpp::CameraComponent
 * @Provenance sha256=99c54353731e267c5f1e5085fe5f07663c3d33c84a2ac6e41bd4cdcc6eb7e5b9; lines 247-280.
 * @Provenance Oracle NewFOV=120, FieldOfViewSet true. Extra: local construct FOV 0,
 * @Provenance FieldOfViewSet false, CameraComp null. FixtureIsolated.
 */

UCLASS()
class ACoverageSpecialCameraActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCameraComponent CameraComp;

	UPROPERTY()
	float InitialFOV = 0.0f;

	UPROPERTY()
	float NewFOV = 0.0f;

	UPROPERTY()
	bool FieldOfViewSet = false;

	/**
	 * WorldStory: BeginPlay reads the field of view, widens it to 120, then reads
	 * it back and records that the write took.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CameraComponent
	 * @Inputs a default-attached UCameraComponent
	 * @Return NewFOV == 120 and FieldOfViewSet true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CameraComp != nullptr)
		{
			InitialFOV = CameraComp.FieldOfView;

			CameraComp.FieldOfView = 120.0f;

			NewFOV = CameraComp.FieldOfView;
			FieldOfViewSet = NewFOV > 119.0f;
		}
	}

	/**
	 * Observe that a locally constructed actor has no field of view and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.CameraComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both fields of view are 0, the flag is clear and both components are null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialFOV != 0.0f)
		{
			return false;
		}
		if (NewFOV != 0.0f)
		{
			return false;
		}
		if (FieldOfViewSet)
		{
			return false;
		}
		if (CameraComp != nullptr)
		{
			return false;
		}
		return Root == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CameraComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 120 with the flag set and the other stays at 0
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialCameraActor Second)
	{
		if (Second is null)
		{
			throw("CameraComponent setup: required Second is null");
		}
		NewFOV = 120.0f;
		FieldOfViewSet = true;

		if (NewFOV != 120.0f)
		{
			return false;
		}
		if (!FieldOfViewSet)
		{
			return false;
		}
		if (Second.NewFOV != 0.0f)
		{
			return false;
		}
		return !Second.FieldOfViewSet;
	}
}
