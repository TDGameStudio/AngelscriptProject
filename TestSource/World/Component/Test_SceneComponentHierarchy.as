// Theme: World.Component. WorldStory: GetAttachParent and GetChildrenComponents.
// C++: AngelscriptCoverageSceneComponentTests.cpp::SceneComponentHierarchy
// sha256=8ccb67c9dc0dd4175f610424e774fe98d7c779d7739ecba59fb7e9ccd82e4117; lines 552-598.
// Oracle Child1HasParent true, GrandChildParentIsChild1 true, RootChildrenCount=2,
// Child1ChildrenCount=1. Extra: local construct flags false, counts 0, handles null.
// FixtureIsolated.

UCLASS()
class ACoverageSceneComponentHierarchyActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child1;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child2;

	UPROPERTY(DefaultComponent, Attach=Child1)
	USceneComponent GrandChild;

	UPROPERTY()
	bool Child1HasParent = false;

	UPROPERTY()
	bool GrandChildParentIsChild1 = false;

	UPROPERTY()
	int RootChildrenCount = 0;

	UPROPERTY()
	int Child1ChildrenCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		USceneComponent Child1Parent = Child1.GetAttachParent();
		Child1HasParent = (Child1Parent == Root);

		USceneComponent GrandChildParent = GrandChild.GetAttachParent();
		GrandChildParentIsChild1 = (GrandChildParent == Child1);

		TArray<USceneComponent> RootChildren;
		Root.GetChildrenComponents(false, RootChildren);
		RootChildrenCount = RootChildren.Num();

		TArray<USceneComponent> Child1Children;
		Child1.GetChildrenComponents(false, Child1Children);
		Child1ChildrenCount = Child1Children.Num();
	}
}

bool Observe_SceneHierarchy_DefaultEmpty(ACoverageSceneComponentHierarchyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SceneComponentHierarchy setup: required Actor is null");
	}
	return !Actor.Child1HasParent
		&& !Actor.GrandChildParentIsChild1
		&& Actor.RootChildrenCount == 0
		&& Actor.Child1ChildrenCount == 0
		&& Actor.Root == nullptr
		&& Actor.Child1 == nullptr
		&& Actor.Child2 == nullptr
		&& Actor.GrandChild == nullptr;
}

bool Observe_SceneHierarchy_CopyIndependence(ACoverageSceneComponentHierarchyActor First, ACoverageSceneComponentHierarchyActor Second)
{
	if (First is null)
	{
		throw("Test_SceneComponentHierarchy setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SceneComponentHierarchy setup: required Second is null");
	}
	First.RootChildrenCount = 2;
	First.Child1HasParent = true;
	return First.RootChildrenCount == 2
		&& First.Child1HasParent
		&& Second.RootChildrenCount == 0
		&& !Second.Child1HasParent;
}
