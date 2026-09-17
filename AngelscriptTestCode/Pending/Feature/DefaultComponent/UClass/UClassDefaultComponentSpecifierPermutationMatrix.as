/**
 * @version v1
 * @summary A DefaultComponent specifier permutation matrix. C++ checks after BeginPlay that AllComponentsCreated, AttachmentPermutationValid, NonSceneComponentsValid and ScriptComponentsValid are all true. The observers cover the.
 * @topic Feature
 */
/**
 * @version root
 * @summary A DefaultComponent specifier permutation matrix. C++ checks after BeginPlay that AllComponentsCreated, AttachmentPermutationValid, NonSceneComponentsValid and ScriptComponentsValid are all true. The observers cover the.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay records that every component materialized, that the
	 * attachment permutation matches the specifiers, and that script markers
	 * survived.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.UClassDefaultComponentSpecifierPermutationMatrix
	 * @Inputs the specifier permutation DefaultComponents
	 * @Return all four flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has not recorded any permutation
	 * outcomes.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentSpecifierPermutationMatrix
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (AllComponentsCreated)
		{
			return false;
		}
		if (AttachmentPermutationValid)
		{
			return false;
		}
		if (NonSceneComponentsValid)
		{
			return false;
		}
		return !ScriptComponentsValid;
	}

	/**
	 * Observe the zero boundary of LogicMarker.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentSpecifierPermutationMatrix
	 * @Inputs a spawned actor whose Logic component has materialized
	 * @Return LogicMarker after it is set to 0
	 * @Boundary zero marker
	 */
	UFUNCTION()
	int LogicMarkerZeroBoundary()
	{
		if (Logic is null)
		{
			throw("UClassDefaultComponentSpecifierPermutationMatrix setup: required Logic component is null");
		}
		Logic.LogicMarker = 0;
		return Logic.LogicMarker;
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentSpecifierPermutationMatrix
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved AllComponentsCreated
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultComponentPermutationsActor Second)
	{
		if (Second is null)
		{
			throw("UClassDefaultComponentSpecifierPermutationMatrix setup: required Second is null");
		}
		bool Saved = Second.AllComponentsCreated;
		AllComponentsCreated = false;
		return Second.AllComponentsCreated == Saved;
	}
}
/** @end */
