// Theme: Feature.DefaultComponent. WorldStory DefaultComponent specifier permutation matrix.
// C++: AngelscriptCoverageUClassTests.cpp::UClassDefaultComponentSpecifierPermutationMatrix
// After BeginPlay: AllComponentsCreated/AttachmentPermutationValid/NonSceneComponentsValid/ScriptComponentsValid true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
// FixtureIsolated.

UCLASS()
class UCoverageUClassPermutationSceneComponent : USceneComponent
{
	UPROPERTY()
	int SceneMarker = 5;
}

UCLASS()
class UCoverageUClassPermutationLogicComponent : UActorComponent
{
	UPROPERTY()
	int LogicMarker = 7;
}

UCLASS()
class ACoverageUClassDefaultComponentPermutationsActor : AActor
{
	UPROPERTY(ShowOnActor, DefaultComponent, RootComponent, EditAnywhere, BlueprintReadOnly)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="MeshSocket")
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach=Mesh)
	USkeletalMeshComponent Skeletal;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCapsuleComponent Capsule;

	UPROPERTY(DefaultComponent, Attach=Capsule)
	UBoxComponent Box;

	UPROPERTY(DefaultComponent, Attach=Root)
	USphereComponent Sphere;

	UPROPERTY(DefaultComponent, Attach=Root)
	USpringArmComponent SpringArm;

	UPROPERTY(DefaultComponent, Attach=SpringArm)
	UCameraComponent Camera;

	UPROPERTY(DefaultComponent, Attach=Root)
	UPointLightComponent Light;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent)
	UCoverageUClassPermutationLogicComponent Logic;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassPermutationSceneComponent ScriptScene;

	UPROPERTY()
	bool AllComponentsCreated = false;

	UPROPERTY()
	bool AttachmentPermutationValid = false;

	UPROPERTY()
	bool NonSceneComponentsValid = false;

	UPROPERTY()
	bool ScriptComponentsValid = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Root == nullptr ||
			Mesh == nullptr ||
			Skeletal == nullptr ||
			Capsule == nullptr ||
			Box == nullptr ||
			Sphere == nullptr ||
			SpringArm == nullptr ||
			Camera == nullptr ||
			Light == nullptr ||
			Arrow == nullptr ||
			Logic == nullptr ||
			ScriptScene == nullptr)
		{
			return;
		}

		AllComponentsCreated =
			true;

		AttachmentPermutationValid =
			Mesh.GetAttachParent() == Root &&
			Mesh.GetAttachSocketName() == n"MeshSocket" &&
			Skeletal.GetAttachParent() == Mesh &&
			Capsule.GetAttachParent() == Root &&
			Box.GetAttachParent() == Capsule &&
			Sphere.GetAttachParent() == Root &&
			SpringArm.GetAttachParent() == Root &&
			Camera.GetAttachParent() == SpringArm &&
			Light.GetAttachParent() == Root &&
			Arrow.GetAttachParent() == Root &&
			ScriptScene.GetAttachParent() == Root;

		NonSceneComponentsValid =
			Logic.GetOwner() == this &&
			Logic.LogicMarker == 7;

		ScriptComponentsValid =
			ScriptScene.GetOwner() == this &&
			ScriptScene.SceneMarker == 5;
	}
}

bool Observe_Permutation_EmptyDefaultIsNull()
{
	ACoverageUClassDefaultComponentPermutationsActor Actor;
	return Actor == nullptr;
}

bool Observe_Permutation_FlagsBeforeBeginPlay(ACoverageUClassDefaultComponentPermutationsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0120 setup: required ACoverageUClassDefaultComponentPermutationsActor is null");
	}
	return !Actor.AllComponentsCreated
		&& !Actor.AttachmentPermutationValid
		&& !Actor.NonSceneComponentsValid
		&& !Actor.ScriptComponentsValid;
}

int Observe_Permutation_LogicMarkerZeroBoundary(ACoverageUClassDefaultComponentPermutationsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0120 setup: required ACoverageUClassDefaultComponentPermutationsActor is null");
	}
	if (Actor.Logic == nullptr)
	{
		throw("TS-FEAT-0120 setup: required Logic component is null");
	}
	Actor.Logic.LogicMarker = 0;
	return Actor.Logic.LogicMarker;
}

bool Observe_Permutation_CopyIndependent(
	ACoverageUClassDefaultComponentPermutationsActor First,
	ACoverageUClassDefaultComponentPermutationsActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0120 setup: required ACoverageUClassDefaultComponentPermutationsActor pair is null");
	}
	bool Saved = Second.AllComponentsCreated;
	First.AllComponentsCreated = false;
	return Second.AllComponentsCreated == Saved;
}
