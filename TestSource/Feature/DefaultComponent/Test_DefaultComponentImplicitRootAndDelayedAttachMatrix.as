// Theme: Feature.DefaultComponent. WorldStory implicit root, delayed Attach, non-scene ownership.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentImplicitRootAndDelayedAttachMatrix
// After BeginPlay: FirstSceneBecameRoot/SecondSceneAttachedToRoot/LogicHasNoSceneAttachment/DelayedAttachResolved true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
// FixtureIsolated.

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
}

bool Observe_ImplicitRoot_EmptyDefaultIsNull()
{
	ACoverageUClassDefaultComponentImplicitRoot Actor;
	return Actor == nullptr;
}

bool Observe_ImplicitRoot_FlagsBeforeBeginPlay(ACoverageUClassDefaultComponentImplicitRoot Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0095 setup: required ACoverageUClassDefaultComponentImplicitRoot is null");
	}
	return !Actor.FirstSceneBecameRoot
		&& !Actor.SecondSceneAttachedToRoot
		&& !Actor.LogicHasNoSceneAttachment
		&& !Actor.DelayedAttachResolved;
}

bool Observe_ImplicitRoot_CopyIndependent(
	ACoverageUClassDefaultComponentImplicitRoot First,
	ACoverageUClassDefaultComponentImplicitRoot Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0095 setup: required ACoverageUClassDefaultComponentImplicitRoot pair is null");
	}
	bool Saved = Second.FirstSceneBecameRoot;
	First.FirstSceneBecameRoot = false;
	return Second.FirstSceneBecameRoot == Saved;
}
