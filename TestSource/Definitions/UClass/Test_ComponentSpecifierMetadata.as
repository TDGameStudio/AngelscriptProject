// Theme: Definitions.UClass. WorldStory DefaultComponent AttachSocket/ShowOnActor metadata.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::ComponentSpecifierMetadata
// Oracle after BeginPlay: ChildAttachedToRoot=true. Extra: unset handle is null;
// pre-BeginPlay ChildAttachedToRoot=false. FixtureIsolated.

UCLASS()
class AComponentSpecifierMetadataActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root, AttachSocket="CoverageSocket", ShowOnActor, EditAnywhere, BlueprintReadOnly)
	USceneComponent Child;

	UPROPERTY()
	bool ChildAttachedToRoot = false;

	UPROPERTY()
	FName ChildAttachSocket;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ChildAttachedToRoot = Child.GetAttachParent() == Root;
		ChildAttachSocket = Child.GetAttachSocketName();
	}
}

bool Observe_ComponentSpecifier_EmptyDefaultIsNull()
{
	AComponentSpecifierMetadataActor Actor;
	return Actor == nullptr;
}

bool Observe_ComponentSpecifier_ChildAttachedDefaultFalse(AComponentSpecifierMetadataActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0036 setup: required AComponentSpecifierMetadataActor is null");
	}
	return Actor.ChildAttachedToRoot == false;
}
