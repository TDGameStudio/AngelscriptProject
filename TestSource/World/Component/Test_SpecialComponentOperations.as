// Theme: World.Component. WorldStory: Arrow/Audio/Input tags, GetComponentByClass,
// NewObject runtime arrow activate/deactivate/destroy.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::SpecialComponentOperations
// sha256=f852057193132e3cd40d8c60693d36d02dd336defe5ba1ec4c7c61ba73a96a03; lines 916-1013.
// Oracle FoundAudioByClass true, TaggedSpecialComponentCount=3, ArrowHasTag true,
// owner/world matched, RuntimeArrowCreated/Activated true.
// Extra: local construct flags false, count 0, RuntimeArrow null. FixtureIsolated.

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
}

bool Observe_SpecialOperations_DefaultEmpty(ACoverageSpecialComponentOperationsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SpecialComponentOperations setup: required Actor is null");
	}
	return !Actor.FoundAudioByClass
		&& Actor.TaggedSpecialComponentCount == 0
		&& !Actor.ArrowHasTag
		&& !Actor.AudioOwnerMatched
		&& !Actor.InputOwnerMatched
		&& !Actor.AudioWorldMatched
		&& !Actor.RuntimeArrowCreated
		&& !Actor.RuntimeArrowActivated
		&& !Actor.RuntimeArrowDeactivated
		&& !Actor.RuntimeArrowDestroyed
		&& Actor.RuntimeArrow == nullptr
		&& Actor.Root == nullptr
		&& Actor.Arrow == nullptr
		&& Actor.Audio == nullptr
		&& Actor.Input == nullptr;
}

bool Observe_SpecialOperations_CopyIndependence(ACoverageSpecialComponentOperationsActor First, ACoverageSpecialComponentOperationsActor Second)
{
	if (First is null)
	{
		throw("Test_SpecialComponentOperations setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SpecialComponentOperations setup: required Second is null");
	}
	First.FoundAudioByClass = true;
	First.TaggedSpecialComponentCount = 3;
	return First.FoundAudioByClass
		&& First.TaggedSpecialComponentCount == 3
		&& !Second.FoundAudioByClass
		&& Second.TaggedSpecialComponentCount == 0;
}
