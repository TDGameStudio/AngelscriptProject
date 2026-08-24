// Theme: Feature.DefaultComponent. WorldStory ShowOnActor / hidden / editable default components.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentShowOnActorSpecifierSurface
// After BeginPlay: VisibleArrowAttached/HiddenSceneAttached/EditableSceneAttached all true.
// Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
// FixtureIsolated.

UCLASS()
class ACoverageUClassDefaultComponentShowOnActor : AActor
{
	UPROPERTY(ShowOnActor, DefaultComponent, RootComponent, EditAnywhere, BlueprintReadOnly, Category="Coverage|Root")
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, ShowOnActor, EditAnywhere, BlueprintReadWrite, Category="Coverage|Visible")
	UArrowComponent VisibleArrow;

	UPROPERTY(DefaultComponent, Attach=Root, BlueprintReadOnly, Category="Coverage|Hidden")
	USceneComponent HiddenScene;

	UPROPERTY(DefaultComponent, Attach=Root, EditAnywhere, Category="Coverage|Editable")
	USceneComponent EditableScene;

	UPROPERTY()
	bool VisibleArrowAttached = false;

	UPROPERTY()
	bool HiddenSceneAttached = false;

	UPROPERTY()
	bool EditableSceneAttached = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VisibleArrowAttached =
			VisibleArrow != nullptr &&
			Root != nullptr &&
			VisibleArrow.GetAttachParent() == Root;

		HiddenSceneAttached =
			HiddenScene != nullptr &&
			Root != nullptr &&
			HiddenScene.GetAttachParent() == Root;

		EditableSceneAttached =
			EditableScene != nullptr &&
			Root != nullptr &&
			EditableScene.GetAttachParent() == Root;
	}
}

bool Observe_ShowOnActor_EmptyDefaultIsNull()
{
	ACoverageUClassDefaultComponentShowOnActor Actor;
	return Actor == nullptr;
}

bool Observe_ShowOnActor_FlagsBeforeBeginPlay(ACoverageUClassDefaultComponentShowOnActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0092 setup: required ACoverageUClassDefaultComponentShowOnActor is null");
	}
	return !Actor.VisibleArrowAttached
		&& !Actor.HiddenSceneAttached
		&& !Actor.EditableSceneAttached;
}

bool Observe_ShowOnActor_CopyIndependent(
	ACoverageUClassDefaultComponentShowOnActor First,
	ACoverageUClassDefaultComponentShowOnActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0092 setup: required ACoverageUClassDefaultComponentShowOnActor pair is null");
	}
	bool Saved = Second.VisibleArrowAttached;
	First.VisibleArrowAttached = false;
	return Second.VisibleArrowAttached == Saved;
}
