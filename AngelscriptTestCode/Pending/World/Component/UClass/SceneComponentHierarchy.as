/**
 * @version v1
 * @summary GetAttachParent and GetChildrenComponents across a root with two children and one grandchild. C++ verifies both parent links and both child counts. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary GetAttachParent and GetChildrenComponents across a root with two children and one grandchild. C++ verifies both parent links and both child counts. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay walks both attach parents and counts the children at two
	 * levels of the hierarchy.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SceneComponentHierarchy
	 * @Inputs four default-attached scene components
	 * @Return both parent flags true, RootChildrenCount 2, Child1ChildrenCount 1
	 */
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

	/**
	 * Observe that a locally constructed actor has no counts, no flags and no handles.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentHierarchy
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both flags are clear, both counts are 0 and all four handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Child1HasParent)
		{
			return false;
		}
		if (GrandChildParentIsChild1)
		{
			return false;
		}
		if (RootChildrenCount != 0)
		{
			return false;
		}
		if (Child1ChildrenCount != 0)
		{
			return false;
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Child1 != nullptr)
		{
			return false;
		}
		if (Child2 != nullptr)
		{
			return false;
		}
		return GrandChild == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SceneComponentHierarchy
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the walked state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSceneComponentHierarchyActor Second)
	{
		if (Second is null)
		{
			throw("SceneComponentHierarchy setup: required Second is null");
		}
		RootChildrenCount = 2;
		Child1HasParent = true;

		if (RootChildrenCount != 2)
		{
			return false;
		}
		if (!Child1HasParent)
		{
			return false;
		}
		if (Second.RootChildrenCount != 0)
		{
			return false;
		}
		return !Second.Child1HasParent;
	}
}
/** @end */
