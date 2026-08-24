// Theme: Feature.DefaultComponent. WorldStory native DefaultComponent type matrix.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentNativeComponentTypeMatrix
// After BeginPlay: AllNativeComponentsCreated/NativeSceneAttachmentsValid/NativeNonSceneComponentValid true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
// FixtureIsolated.

UCLASS()
class UCoverageUClassNativeMatrixLogic : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentNativeTypes : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="MeshSocket")
	UStaticMeshComponent StaticMesh;

	UPROPERTY(DefaultComponent, Attach=StaticMesh)
	USkeletalMeshComponent SkeletalMesh;

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
	UPointLightComponent PointLight;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent)
	UCoverageUClassNativeMatrixLogic LogicNonScene;

	UPROPERTY()
	bool AllNativeComponentsCreated = false;

	UPROPERTY()
	bool NativeSceneAttachmentsValid = false;

	UPROPERTY()
	bool NativeNonSceneComponentValid = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Root == nullptr ||
			StaticMesh == nullptr ||
			SkeletalMesh == nullptr ||
			Capsule == nullptr ||
			Box == nullptr ||
			Sphere == nullptr ||
			SpringArm == nullptr ||
			Camera == nullptr ||
			PointLight == nullptr ||
			Arrow == nullptr ||
			LogicNonScene == nullptr)
		{
			return;
		}

		AllNativeComponentsCreated = true;

		NativeSceneAttachmentsValid =
			StaticMesh.GetAttachParent() == Root &&
			StaticMesh.GetAttachSocketName() == n"MeshSocket" &&
			SkeletalMesh.GetAttachParent() == StaticMesh &&
			Capsule.GetAttachParent() == Root &&
			Box.GetAttachParent() == Capsule &&
			Sphere.GetAttachParent() == Root &&
			SpringArm.GetAttachParent() == Root &&
			Camera.GetAttachParent() == SpringArm &&
			PointLight.GetAttachParent() == Root &&
			Arrow.GetAttachParent() == Root;

		NativeNonSceneComponentValid =
			LogicNonScene.GetOwner() == this;
	}
}

bool Observe_NativeTypes_EmptyDefaultIsNull()
{
	ACoverageUClassDefaultComponentNativeTypes Actor;
	return Actor == nullptr;
}

bool Observe_NativeTypes_FlagsBeforeBeginPlay(ACoverageUClassDefaultComponentNativeTypes Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0093 setup: required ACoverageUClassDefaultComponentNativeTypes is null");
	}
	return !Actor.AllNativeComponentsCreated
		&& !Actor.NativeSceneAttachmentsValid
		&& !Actor.NativeNonSceneComponentValid;
}

bool Observe_NativeTypes_CopyIndependent(
	ACoverageUClassDefaultComponentNativeTypes First,
	ACoverageUClassDefaultComponentNativeTypes Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0093 setup: required ACoverageUClassDefaultComponentNativeTypes pair is null");
	}
	bool Saved = Second.AllNativeComponentsCreated;
	First.AllNativeComponentsCreated = false;
	return Second.AllNativeComponentsCreated == Saved;
}
