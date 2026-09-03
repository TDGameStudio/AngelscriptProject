/**
 * Root and Child DefaultComponent properties point at instances. C++ checks
 * Root == GetRootComponent(), Child.GetAttachParent() == Root, and names
 * Root/Child. The observers cover the local construct default, those instance
 * links, the scripted names, and copy independence.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.DefaultComponentPropertiesPointToInstances
 * @Harness UClass
 * @Tag Feature.DefaultComponent.DefaultComponentPropertiesPointToInstances
 * @Provenance Theme: Feature.DefaultComponent. WorldStory Root/Child DefaultComponent properties point at instances.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::DefaultComponentPropertiesPointToInstances
 * @Provenance Oracle: Root == GetRootComponent(); Child.GetAttachParent() == Root; names Root/Child.
 * @Provenance Extra: unset handle is null; two actors keep distinct Root instances.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ATestDefaultComponentExtendedProperties : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent Child;

	/**
	 * Observe that a locally constructed actor has neither Root nor Child.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentPropertiesPointToInstances
	 * @Inputs an actor that has not been spawned
	 * @Return true when Root and Child are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (Root != nullptr)
		{
			return false;
		}
		return Child == nullptr;
	}

	/**
	 * Observe that Root is the actor's root component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentPropertiesPointToInstances
	 * @Inputs a spawned actor whose Root has materialized
	 * @Return true when Root is non-null and equals GetRootComponent()
	 */
	UFUNCTION()
	bool RootIsActorRoot()
	{
		if (Root == nullptr)
		{
			return false;
		}
		return Root == GetRootComponent();
	}

	/**
	 * Observe that Child is attached to Root.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentPropertiesPointToInstances
	 * @Inputs a spawned actor whose Child has materialized
	 * @Return true when Child's attach parent is Root
	 */
	UFUNCTION()
	bool ChildAttachedToRoot()
	{
		if (Child == nullptr)
		{
			return false;
		}
		if (Root == nullptr)
		{
			return false;
		}
		return Child.GetAttachParent() == Root;
	}

	/**
	 * Observe that the scripted component names are Root and Child.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentPropertiesPointToInstances
	 * @Inputs a spawned actor whose components have materialized
	 * @Return true when Root and Child keep those FNames
	 */
	UFUNCTION()
	bool ScriptedNames()
	{
		if (Root == nullptr)
		{
			return false;
		}
		if (Child == nullptr)
		{
			return false;
		}
		if (Root.GetName() != n"Root")
		{
			return false;
		}
		return Child.GetName() == n"Child";
	}

	/**
	 * Observe that a second instance keeps its own distinct Root.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentPropertiesPointToInstances
	 * @Inputs this actor plus a second spawned actor
	 * @Return true when both Roots are non-null and not the same instance
	 * @Param Second the other actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestDefaultComponentExtendedProperties Second)
	{
		if (Second is null)
		{
			throw("DefaultComponentPropertiesPointToInstances setup: required Second is null");
		}
		if (Root == nullptr)
		{
			return false;
		}
		if (Second.Root == nullptr)
		{
			return false;
		}
		return Root != Second.Root;
	}
}
