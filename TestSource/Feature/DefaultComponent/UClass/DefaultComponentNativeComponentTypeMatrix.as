/**
 * A native DefaultComponent type matrix. C++ checks after BeginPlay that
 * AllNativeComponentsCreated, NativeSceneAttachmentsValid and
 * NativeNonSceneComponentValid are true. The observers cover the local
 * construct default and copy independence.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.DefaultComponentNativeComponentTypeMatrix
 * @Harness UClass
 * @Tag Feature.DefaultComponent.DefaultComponentNativeComponentTypeMatrix
 * @Provenance Theme: Feature.DefaultComponent. WorldStory native DefaultComponent type matrix.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentNativeComponentTypeMatrix
 * @Provenance After BeginPlay: AllNativeComponentsCreated/NativeSceneAttachmentsValid/NativeNonSceneComponentValid true.
 * @Provenance Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay records that every native component materialized,
	 * that the scene attachments match the specifier matrix, and that the
	 * non-scene logic component is owned by this actor.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.DefaultComponentNativeComponentTypeMatrix
	 * @Inputs the native DefaultComponent matrix
	 * @Return all three flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has not recorded any native-type
	 * outcomes.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentNativeComponentTypeMatrix
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (AllNativeComponentsCreated)
		{
			return false;
		}
		if (NativeSceneAttachmentsValid)
		{
			return false;
		}
		return !NativeNonSceneComponentValid;
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentNativeComponentTypeMatrix
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved AllNativeComponentsCreated
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultComponentNativeTypes Second)
	{
		if (Second is null)
		{
			throw("DefaultComponentNativeComponentTypeMatrix setup: required Second is null");
		}
		bool Saved = Second.AllNativeComponentsCreated;
		AllNativeComponentsCreated = false;
		return Second.AllNativeComponentsCreated == Saved;
	}
}
