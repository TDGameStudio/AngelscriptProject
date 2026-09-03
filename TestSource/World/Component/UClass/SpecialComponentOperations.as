/**
 * Arrow, audio and input components tagged and looked up by class, plus a runtime
 * arrow built with NewObject that is attached, activated, deactivated and
 * destroyed. C++ verifies the flags and the tagged count. The observers cover the
 * local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.SpecialComponentOperations
 * @Harness UClass
 * @Tag World.Component.SpecialComponentOperations
 * @Provenance Theme: World.Component. WorldStory: Arrow/Audio/Input tags, GetComponentByClass,
 * @Provenance NewObject runtime arrow activate/deactivate/destroy.
 * @Provenance C++: AngelscriptCoverageSpecialComponentTests.cpp::SpecialComponentOperations
 * @Provenance sha256=f852057193132e3cd40d8c60693d36d02dd336defe5ba1ec4c7c61ba73a96a03; lines 916-1013.
 * @Provenance Oracle FoundAudioByClass true, TaggedSpecialComponentCount=3, ArrowHasTag true,
 * @Provenance owner/world matched, RuntimeArrowCreated/Activated true.
 * @Provenance Extra: local construct flags false, count 0, RuntimeArrow null. FixtureIsolated.
 */

UCLASS()
class ACoverageSpecialComponentOperationsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UArrowComponent Arrow;

	UPROPERTY(DefaultComponent, Attach=Root)
	UAudioComponent Audio;

	UPROPERTY(DefaultComponent)
	UInputComponent Input;

	UPROPERTY()
	UArrowComponent RuntimeArrow;

	UPROPERTY()
	bool FoundAudioByClass = false;

	UPROPERTY()
	int TaggedSpecialComponentCount = 0;

	UPROPERTY()
	bool ArrowHasTag = false;

	UPROPERTY()
	bool AudioOwnerMatched = false;

	UPROPERTY()
	bool InputOwnerMatched = false;

	UPROPERTY()
	bool AudioWorldMatched = false;

	UPROPERTY()
	bool RuntimeArrowCreated = false;

	UPROPERTY()
	bool RuntimeArrowActivated = false;

	UPROPERTY()
	bool RuntimeArrowDeactivated = false;

	UPROPERTY()
	bool RuntimeArrowDestroyed = false;

	/**
	 * WorldStory: BeginPlay tags all three special components, resolves the audio one
	 * by class, counts the tagged components, then walks a runtime arrow through its
	 * whole lifecycle.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SpecialComponentOperations
	 * @Inputs three default components plus a NewObject arrow
	 * @Return all flags true and TaggedSpecialComponentCount == 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Arrow != nullptr)
		{
			Arrow.ComponentTags.Add(n"SpecialCoverage");
			ArrowHasTag = Arrow.ComponentHasTag(n"SpecialCoverage");
		}

		if (Audio != nullptr)
		{
			Audio.ComponentTags.Add(n"SpecialCoverage");
			Audio.SetVolumeMultiplier(0.25f);
			Audio.Stop();
			AudioOwnerMatched = Audio.GetOwner() == this;
			AudioWorldMatched = Audio.GetWorld() == GetWorld();
		}

		if (Input != nullptr)
		{
			Input.ComponentTags.Add(n"SpecialCoverage");
			InputOwnerMatched = Input.GetOwner() == this;
		}

		FoundAudioByClass = Cast<UAudioComponent>(GetComponentByClass(UAudioComponent::StaticClass())) == Audio;

		TArray<UActorComponent> TaggedComponents = GetComponentsByTag(UActorComponent::StaticClass(), n"SpecialCoverage");
		TaggedSpecialComponentCount = TaggedComponents.Num();

		RuntimeArrow = Cast<UArrowComponent>(NewObject(this, UArrowComponent::StaticClass(), n"RuntimeArrow", true));
		RuntimeArrowCreated = RuntimeArrow != nullptr;
		if (RuntimeArrow == nullptr)
		{
			return;
		}

		RuntimeArrow.AttachToComponent(Root, NAME_None, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, EAttachmentRule::KeepRelative, false);

		RuntimeArrow.Activate(true);
		RuntimeArrowActivated = RuntimeArrow.IsActive();

		RuntimeArrow.Deactivate();
		RuntimeArrowDeactivated = !RuntimeArrow.IsActive();

		RuntimeArrow.DestroyComponent();
		RuntimeArrowDestroyed = RuntimeArrow.IsBeingDestroyed();
	}

	/**
	 * Observe that a locally constructed actor has no flags, no count and no components.
	 *
	 * @Kind Observe
	 * @Covers Component.SpecialComponentOperations
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all flags are clear, the count is 0 and all five handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (FoundAudioByClass)
		{
			return false;
		}
		if (TaggedSpecialComponentCount != 0)
		{
			return false;
		}
		if (ArrowHasTag)
		{
			return false;
		}
		if (AudioOwnerMatched)
		{
			return false;
		}
		if (InputOwnerMatched)
		{
			return false;
		}
		if (AudioWorldMatched)
		{
			return false;
		}
		if (RuntimeArrowCreated)
		{
			return false;
		}
		if (RuntimeArrowActivated)
		{
			return false;
		}
		if (RuntimeArrowDeactivated)
		{
			return false;
		}
		if (RuntimeArrowDestroyed)
		{
			return false;
		}
		if (RuntimeArrow != nullptr)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Arrow != nullptr)
		{
			return false;
		}
		if (Audio != nullptr)
		{
			return false;
		}
		return Input == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SpecialComponentOperations
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the found state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialComponentOperationsActor Second)
	{
		if (Second is null)
		{
			throw("SpecialComponentOperations setup: required Second is null");
		}
		FoundAudioByClass = true;
		TaggedSpecialComponentCount = 3;

		if (!FoundAudioByClass)
		{
			return false;
		}
		if (TaggedSpecialComponentCount != 3)
		{
			return false;
		}
		if (Second.FoundAudioByClass)
		{
			return false;
		}
		return Second.TaggedSpecialComponentCount == 0;
	}
}
