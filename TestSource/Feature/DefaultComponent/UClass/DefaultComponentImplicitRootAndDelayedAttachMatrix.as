/**
 * Implicit root, delayed Attach, and non-scene ownership. C++ checks after
 * BeginPlay that FirstSceneBecameRoot, SecondSceneAttachedToRoot,
 * LogicHasNoSceneAttachment and DelayedAttachResolved are all true. The
 * observers cover the local construct default and copy independence.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.DefaultComponentImplicitRootAndDelayedAttachMatrix
 * @Harness UClass
 * @Tag Feature.DefaultComponent.DefaultComponentImplicitRootAndDelayedAttachMatrix
 * @Provenance Theme: Feature.DefaultComponent. WorldStory implicit root, delayed Attach, non-scene ownership.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentImplicitRootAndDelayedAttachMatrix
 * @Provenance After BeginPlay: FirstSceneBecameRoot/SecondSceneAttachedToRoot/LogicHasNoSceneAttachment/DelayedAttachResolved true.
 * @Provenance Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UCoverageUClassDefaultComponentImplicitLogic : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentImplicitRoot : AActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent FirstScene;

	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentImplicitLogic Logic;

	UPROPERTY(DefaultComponent, Attach=SecondScene, AttachSocket="DelayedSocket")
	USceneComponent DelayedChild;

	UPROPERTY(DefaultComponent)
	USceneComponent SecondScene;

	UPROPERTY()
	bool FirstSceneBecameRoot = false;

	UPROPERTY()
	bool SecondSceneAttachedToRoot = false;

	UPROPERTY()
	bool LogicHasNoSceneAttachment = false;

	UPROPERTY()
	bool DelayedAttachResolved = false;

	/**
	 * WorldStory: BeginPlay records the implicit root, delayed attach, and
	 * non-scene ownership outcomes.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.DefaultComponentImplicitRootAndDelayedAttachMatrix
	 * @Inputs FirstScene, Logic, DelayedChild and SecondScene default components
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FirstSceneBecameRoot =
			FirstScene != nullptr &&
			FirstScene.GetAttachParent() == nullptr;

		SecondSceneAttachedToRoot =
			SecondScene != nullptr &&
			FirstScene != nullptr &&
			SecondScene.GetAttachParent() == FirstScene;

		LogicHasNoSceneAttachment =
			Logic != nullptr &&
			Logic.GetOwner() == this;

		DelayedAttachResolved =
			DelayedChild != nullptr &&
			SecondScene != nullptr &&
			DelayedChild.GetAttachParent() == SecondScene &&
			DelayedChild.GetAttachSocketName() == n"DelayedSocket";
	}

	/**
	 * Observe that a locally constructed actor has not recorded any of the four
	 * implicit-root outcomes.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentImplicitRootAndDelayedAttachMatrix
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
	 * @Covers DefaultComponent.DefaultComponentImplicitRootAndDelayedAttachMatrix
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved FirstSceneBecameRoot
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultComponentImplicitRoot Second)
	{
		if (Second is null)
		{
			throw("DefaultComponentImplicitRootAndDelayedAttachMatrix setup: required Second is null");
		}
		bool Saved = Second.FirstSceneBecameRoot;
		FirstSceneBecameRoot = false;
		return Second.FirstSceneBecameRoot == Saved;
	}
}
