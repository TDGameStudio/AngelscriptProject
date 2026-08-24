// Theme: Feature.DefaultComponent. WorldStory extra native DefaultComponent types.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::AdditionalDefaultComponentTypes
// After BeginPlay: ArrowValid/AudioValid/InputValid/PointLightValid/SkeletalMeshValid/SceneTypesAttached all true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
// FixtureIsolated.

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
}

bool Observe_AdditionalTypes_EmptyDefaultIsNull()
{
	ACoverageSpecialAdditionalTypesActor Actor;
	return Actor == nullptr;
}

bool Observe_AdditionalTypes_FlagsBeforeBeginPlay(ACoverageSpecialAdditionalTypesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0077 setup: required ACoverageSpecialAdditionalTypesActor is null");
	}
	return !Actor.ArrowValid
		&& !Actor.AudioValid
		&& !Actor.InputValid
		&& !Actor.PointLightValid
		&& !Actor.SkeletalMeshValid
		&& !Actor.SceneTypesAttached;
}

bool Observe_AdditionalTypes_CopyIndependent(
	ACoverageSpecialAdditionalTypesActor First,
	ACoverageSpecialAdditionalTypesActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0077 setup: required ACoverageSpecialAdditionalTypesActor pair is null");
	}
	bool Saved = Second.ArrowValid;
	First.ArrowValid = false;
	return Second.ArrowValid == Saved;
}
