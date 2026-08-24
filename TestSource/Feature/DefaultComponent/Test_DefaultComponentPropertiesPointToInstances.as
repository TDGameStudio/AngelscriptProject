// Theme: Feature.DefaultComponent. WorldStory Root/Child DefaultComponent properties point at instances.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::DefaultComponentPropertiesPointToInstances
// Oracle: Root == GetRootComponent(); Child.GetAttachParent() == Root; names Root/Child.
// Extra: unset handle is null; two actors keep distinct Root instances.
// FixtureIsolated.

UCLASS()
class ATestDefaultComponentExtendedProperties : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent Child;
}

bool Observe_ExtendedProperties_EmptyDefaultIsNull()
{
	ATestDefaultComponentExtendedProperties Actor;
	return Actor == nullptr;
}

bool Observe_ExtendedProperties_RootIsActorRoot(ATestDefaultComponentExtendedProperties Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0184 setup: required ATestDefaultComponentExtendedProperties is null");
	}
	return Actor.Root != nullptr && Actor.Root == Actor.GetRootComponent();
}

bool Observe_ExtendedProperties_ChildAttachedToRoot(ATestDefaultComponentExtendedProperties Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0184 setup: required ATestDefaultComponentExtendedProperties is null");
	}
	return Actor.Child != nullptr
		&& Actor.Root != nullptr
		&& Actor.Child.GetAttachParent() == Actor.Root;
}

bool Observe_ExtendedProperties_ScriptedNames(ATestDefaultComponentExtendedProperties Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0184 setup: required ATestDefaultComponentExtendedProperties is null");
	}
	return Actor.Root != nullptr
		&& Actor.Child != nullptr
		&& Actor.Root.GetName() == n"Root"
		&& Actor.Child.GetName() == n"Child";
}

bool Observe_ExtendedProperties_CopyIndependent(
	ATestDefaultComponentExtendedProperties First,
	ATestDefaultComponentExtendedProperties Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0184 setup: required ATestDefaultComponentExtendedProperties pair is null");
	}
	return First.Root != nullptr && Second.Root != nullptr && First.Root != Second.Root;
}
