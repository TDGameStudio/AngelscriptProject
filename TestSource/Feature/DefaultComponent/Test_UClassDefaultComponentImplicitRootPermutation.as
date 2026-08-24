// Theme: Feature.DefaultComponent. WorldStory implicit-root DefaultComponent permutation.
// C++: AngelscriptCoverageUClassTests.cpp::UClassDefaultComponentImplicitRootPermutation
// After BeginPlay: FirstSceneBecameRoot/SecondSceneAttachedToRoot/LogicHasNoSceneAttachment/DelayedAttachResolved true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
// FixtureIsolated.

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
}

bool Observe_ImplicitPermutation_EmptyDefaultIsNull()
{
	ACoverageUClassImplicitDefaultComponentActor Actor;
	return Actor == nullptr;
}

bool Observe_ImplicitPermutation_FlagsBeforeBeginPlay(ACoverageUClassImplicitDefaultComponentActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0121 setup: required ACoverageUClassImplicitDefaultComponentActor is null");
	}
	return !Actor.FirstSceneBecameRoot
		&& !Actor.SecondSceneAttachedToRoot
		&& !Actor.LogicHasNoSceneAttachment
		&& !Actor.DelayedAttachResolved;
}

bool Observe_ImplicitPermutation_CopyIndependent(
	ACoverageUClassImplicitDefaultComponentActor First,
	ACoverageUClassImplicitDefaultComponentActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0121 setup: required ACoverageUClassImplicitDefaultComponentActor pair is null");
	}
	bool Saved = Second.FirstSceneBecameRoot;
	First.FirstSceneBecameRoot = false;
	return Second.FirstSceneBecameRoot == Saved;
}
