/**
 * ShowOnActor, hidden and editable default components. C++ checks after
 * BeginPlay that VisibleArrowAttached, HiddenSceneAttached and
 * EditableSceneAttached are all true. The observers cover the local construct
 * default and copy independence.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.DefaultComponentShowOnActorSpecifierSurface
 * @Harness UClass
 * @Tag Feature.DefaultComponent.DefaultComponentShowOnActorSpecifierSurface
 * @Provenance Theme: Feature.DefaultComponent. WorldStory ShowOnActor / hidden / editable default components.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentShowOnActorSpecifierSurface
 * @Provenance After BeginPlay: VisibleArrowAttached/HiddenSceneAttached/EditableSceneAttached all true.
 * @Provenance Extra: unset handle is null; pre-BeginPlay flags stay false. Keep those UPROPERTY names.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay records that the visible, hidden and editable scene
	 * components all attached to Root.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.DefaultComponentShowOnActorSpecifierSurface
	 * @Inputs VisibleArrow, HiddenScene and EditableScene default components
	 * @Return all three flags true
	 */
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

	/**
	 * Observe that a locally constructed actor has not recorded any attachments.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentShowOnActorSpecifierSurface
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three flags are false
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (VisibleArrowAttached)
		{
			return false;
		}
		if (HiddenSceneAttached)
		{
			return false;
		}
		return !EditableSceneAttached;
	}

	/**
	 * Observe that writing this actor leaves a second actor's flags untouched.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentShowOnActorSpecifierSurface
	 * @Inputs this actor plus a second actor
	 * @Return true when the second actor keeps its saved VisibleArrowAttached
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageUClassDefaultComponentShowOnActor Second)
	{
		if (Second is null)
		{
			throw("DefaultComponentShowOnActorSpecifierSurface setup: required Second is null");
		}
		bool Saved = Second.VisibleArrowAttached;
		VisibleArrowAttached = false;
		return Second.VisibleArrowAttached == Saved;
	}
}
