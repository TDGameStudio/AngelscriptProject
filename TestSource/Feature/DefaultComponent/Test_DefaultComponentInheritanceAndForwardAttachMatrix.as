// Theme: Feature.DefaultComponent. WorldStory inherited and forward-declared Attach targets.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInheritanceAndForwardAttachMatrix
// After BeginPlay: BaseAttachmentsPreserved true; ImplicitSceneAttached true.
// Extra: unset handle is null; ForwardChild attaches to ForwardParent + ForwardSocket.
// Keep BaseAttachmentsPreserved/ImplicitSceneAttached. FixtureIsolated.

UCLASS()
class ACoverageUClassDefaultComponentBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="BaseSocket")
	USceneComponent BaseChild;
}

UCLASS()
class ACoverageUClassDefaultComponentDerivedActor : ACoverageUClassDefaultComponentBaseActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent FirstImplicitScene;

	UPROPERTY(DefaultComponent)
	USceneComponent ForwardParent;

	UPROPERTY(DefaultComponent, Attach=ForwardParent, AttachSocket="ForwardSocket")
	USceneComponent ForwardChild;

	UPROPERTY(DefaultComponent)
	USceneComponent DerivedChild;

	UPROPERTY()
	bool BaseAttachmentsPreserved = false;

	UPROPERTY()
	bool ImplicitSceneAttached = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BaseAttachmentsPreserved =
			Root != nullptr &&
			BaseChild != nullptr &&
			Root.GetAttachParent() == nullptr &&
			BaseChild.GetAttachParent() == Root &&
			BaseChild.GetAttachSocketName() == n"BaseSocket";

		ImplicitSceneAttached =
			FirstImplicitScene != nullptr &&
			Root != nullptr &&
			FirstImplicitScene.GetAttachParent() == Root;
	}
}

bool Observe_InheritAttach_EmptyDefaultIsNull()
{
	ACoverageUClassDefaultComponentDerivedActor Actor;
	return Actor == nullptr;
}

bool Observe_InheritAttach_FlagsBeforeBeginPlay(ACoverageUClassDefaultComponentDerivedActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0094 setup: required ACoverageUClassDefaultComponentDerivedActor is null");
	}
	return !Actor.BaseAttachmentsPreserved && !Actor.ImplicitSceneAttached;
}

bool Observe_InheritAttach_ForwardChildSocket(ACoverageUClassDefaultComponentDerivedActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0094 setup: required ACoverageUClassDefaultComponentDerivedActor is null");
	}
	return Actor.ForwardChild != nullptr
		&& Actor.ForwardParent != nullptr
		&& Actor.ForwardChild.GetAttachParent() == Actor.ForwardParent
		&& Actor.ForwardChild.GetAttachSocketName() == n"ForwardSocket";
}

bool Observe_InheritAttach_CopyIndependent(
	ACoverageUClassDefaultComponentDerivedActor First,
	ACoverageUClassDefaultComponentDerivedActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0094 setup: required ACoverageUClassDefaultComponentDerivedActor pair is null");
	}
	bool Saved = Second.BaseAttachmentsPreserved;
	First.BaseAttachmentsPreserved = false;
	return Second.BaseAttachmentsPreserved == Saved;
}
