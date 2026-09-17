/**
 * @version v1
 * @summary Extra native DefaultComponent types on one actor. C++ checks after BeginPlay that ArrowValid, AudioValid, InputValid, PointLightValid, SkeletalMeshValid and SceneTypesAttached are all true. The observers cover the local.
 * @topic Feature
 */
/**
 * @version root
 * @summary Extra native DefaultComponent types on one actor. C++ checks after BeginPlay that ArrowValid, AudioValid, InputValid, PointLightValid, SkeletalMeshValid and SceneTypesAttached are all true. The observers cover the local.
 * @topic Baseline
 */
UCLASS()
class ACoverageSpecialAdditionalTypesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY(DefaultComponent)
	UInputComponent Input;

	UPROPERTY(DefaultComponent, Attach=Root)
	UPointLightComponent PointLight;

	UPROPERTY(DefaultComponent, Attach=Root)
	USkeletalMeshComponent SkeletalMesh;

	UPROPERTY()
	bool ArrowValid = false;

	UPROPERTY()
	bool AudioValid = false;

	UPROPERTY()
	bool InputValid = false;

	UPROPERTY()
	bool PointLightValid = false;

	UPROPERTY()
	bool SkeletalMeshValid = false;

	UPROPERTY()
	bool SceneTypesAttached = false;

	/**
	 * WorldStory: BeginPlay records that each extra native component materialized
	 * and that the scene types attached to Root.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.AdditionalDefaultComponentTypes
	 * @Inputs Arrow, Audio, Input, PointLight and SkeletalMesh default components
	 * @Return all six flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ArrowValid = Arrow != nullptr;
		AudioValid = Audio != nullptr;
		InputValid = Input != nullptr;
		PointLightValid = PointLight != nullptr;
		SkeletalMeshValid = SkeletalMesh != nullptr;

		if (Arrow != nullptr && Audio != nullptr && PointLight != nullptr && SkeletalMesh != nullptr)
		{
			SceneTypesAttached =
				Arrow.GetAttachParent() == Root
				&& Audio.GetAttachParent() == Root
				&& PointLight.GetAttachParent() == Root
				&& SkeletalMesh.GetAttachParent() == Root;
		}
	}

	/**
	 * Observe that a locally constructed actor has not recorded any extra types.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.AdditionalDefaultComponentTypes
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all six flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ArrowValid)
		{
			return false;
		}
		if (AudioValid)
		{
			return false;
		}
		if (InputValid)
		{
			return false;
		}
		if (PointLightValid)
		{
			return false;
		}
		if (SkeletalMeshValid)
		{
			return false;
		}
		return !SceneTypesAttached;
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.AdditionalDefaultComponentTypes
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved ArrowValid
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialAdditionalTypesActor Second)
	{
		if (Second is null)
		{
			throw("AdditionalDefaultComponentTypes setup: required Second is null");
		}
		bool Saved = Second.ArrowValid;
		ArrowValid = false;
		return Second.ArrowValid == Saved;
	}
}
/** @end */
