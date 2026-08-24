// Theme: World.Component. WorldStory: GetComponentByClass, ComponentHasTag,
// GetComponentsByTag, GetComponentsByClass on derived components.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentFindingByClassAndTag
// sha256=2710394b38258e9c9e7fd62d56b6525dc20d992c9d9738936f488fafd119a9f9; lines 2031-2090.
// Oracle: GetComponentByClassFound=true, TaggedComponentCount=2,
// TaggedQueryCount=2, DerivedComponentCount=2. Extra: local construct zeros
// and null derived handles. FixtureIsolated.

UCLASS()
class UCoverageFindBaseComponent : UActorComponent
{
}

UCLASS()
class UCoverageFindDerivedComponent : UCoverageFindBaseComponent
{
}

UCLASS()
class ACoverageComponentFindingByClassAndTagActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageFindDerivedComponent DerivedA;

	UPROPERTY(DefaultComponent)
	UCoverageFindDerivedComponent DerivedB;

	UPROPERTY()
	bool GetComponentByClassFound = false;

	UPROPERTY()
	int TaggedComponentCount = 0;

	UPROPERTY()
	int TaggedQueryCount = 0;

	UPROPERTY()
	int DerivedComponentCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DerivedA.ComponentTags.Add(n"CoverageTag");
		DerivedB.ComponentTags.Add(n"CoverageTag");

		UActorComponent FoundBase = GetComponentByClass(UCoverageFindBaseComponent::StaticClass());
		GetComponentByClassFound = FoundBase != nullptr;

		TArray<UActorComponent> AllComponents;
		GetComponentsByClass(UActorComponent::StaticClass(), AllComponents);
		for (UActorComponent Component : AllComponents)
		{
			if (Component.ComponentHasTag(n"CoverageTag"))
			{
				TaggedComponentCount++;
			}
		}

		TArray<UActorComponent> TaggedComponents = GetComponentsByTag(UActorComponent::StaticClass(), n"CoverageTag");
		TaggedQueryCount = TaggedComponents.Num();

		TArray<UCoverageFindDerivedComponent> DerivedComponents;
		GetComponentsByClass(UCoverageFindDerivedComponent::StaticClass(), DerivedComponents);
		DerivedComponentCount = DerivedComponents.Num();
	}
}

bool Observe_FindingByClassAndTag_DefaultEmpty(ACoverageComponentFindingByClassAndTagActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentFindingByClassAndTag setup: required Actor is null");
	}
	return !Actor.GetComponentByClassFound
		&& Actor.TaggedComponentCount == 0
		&& Actor.TaggedQueryCount == 0
		&& Actor.DerivedComponentCount == 0
		&& Actor.DerivedA == nullptr
		&& Actor.DerivedB == nullptr;
}

bool Observe_FindingByClassAndTag_CopyIndependence(ACoverageComponentFindingByClassAndTagActor First, ACoverageComponentFindingByClassAndTagActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentFindingByClassAndTag setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentFindingByClassAndTag setup: required Second is null");
	}
	First.GetComponentByClassFound = true;
	First.TaggedComponentCount = 2;
	return First.GetComponentByClassFound
		&& First.TaggedComponentCount == 2
		&& !Second.GetComponentByClassFound
		&& Second.TaggedComponentCount == 0;
}
