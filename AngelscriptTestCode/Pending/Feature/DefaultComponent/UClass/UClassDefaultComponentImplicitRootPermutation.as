/**
 * @version v1
 * @summary An implicit-root DefaultComponent permutation. C++ checks after BeginPlay that FirstSceneBecameRoot, SecondSceneAttachedToRoot, LogicHasNoSceneAttachment and DelayedAttachResolved are all true. The observers cover the.
 * @topic Feature
 */
/**
 * @version root
 * @summary An implicit-root DefaultComponent permutation. C++ checks after BeginPlay that FirstSceneBecameRoot, SecondSceneAttachedToRoot, LogicHasNoSceneAttachment and DelayedAttachResolved are all true. The observers cover the.
 * @topic Baseline
 */
UCLASS()
class UCoverageUClassImplicitLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassImplicitDefaultComponentActor : AActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent FirstScene;

	UPROPERTY(DefaultComponent)
	USceneComponent SecondScene;

	UPROPERTY(DefaultComponent)
	UCoverageUClassImplicitLogicComponent Logic;

	UPROPERTY(DefaultComponent, Attach=SecondScene, AttachSocket="DelayedSocket")
	USceneComponent DelayedChild;

	UPROPERTY()
	bool FirstSceneBecameRoot = false;

	UPROPERTY()
	bool SecondSceneAttachedToRoot = false;

	UPROPERTY()
	bool LogicHasNoSceneAttachment = false;

	UPROPERTY()
	bool DelayedAttachResolved = false;

	/**
	 * WorldStory: BeginPlay records the implicit-root permutation outcomes.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.UClassDefaultComponentImplicitRootPermutation
	 * @Inputs FirstScene, SecondScene, Logic and DelayedChild default components
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (FirstScene == nullptr ||
			SecondScene == nullptr ||
			Logic == nullptr ||
			DelayedChild == nullptr)
		{
			return;
		}

		FirstSceneBecameRoot =
			FirstScene.GetAttachParent() == nullptr;
		SecondSceneAttachedToRoot =
			SecondScene.GetAttachParent() == FirstScene;
		LogicHasNoSceneAttachment =
			Logic.GetOwner() == this;
		DelayedAttachResolved =
			DelayedChild.GetAttachParent() == SecondScene &&
			DelayedChild.GetAttachSocketName() == n"DelayedSocket";
	}

	/**
	 * Observe that a locally constructed actor has not recorded any permutation
	 * outcomes.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentImplicitRootPermutation
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FirstSceneBecameRoot)
		{
			return false;
		}
		if (SecondSceneAttachedToRoot)
		{
			return false;
		}
		if (LogicHasNoSceneAttachment)
		{
			return false;
		}
		return !DelayedAttachResolved;
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.UClassDefaultComponentImplicitRootPermutation
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved FirstSceneBecameRoot
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassImplicitDefaultComponentActor Second)
	{
		if (Second is null)
		{
			throw("UClassDefaultComponentImplicitRootPermutation setup: required Second is null");
		}
		bool Saved = Second.FirstSceneBecameRoot;
		FirstSceneBecameRoot = false;
		return Second.FirstSceneBecameRoot == Saved;
	}
}
/** @end */
