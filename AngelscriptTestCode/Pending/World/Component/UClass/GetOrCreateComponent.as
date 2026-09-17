/**
 * @version v1
 * @summary GetOrCreateComponent reusing an existing root versus lazily creating named components. C++ calls the entrypoints by name, so the names are part of the contract and are kept verbatim. The observers cover the.
 * @topic World
 */
/**
 * @version root
 * @summary GetOrCreateComponent reusing an existing root versus lazily creating named components. C++ calls the entrypoints by name, so the names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Baseline
 */
UCLASS()
class ATestActorGetOrCreateComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * Get the existing root by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the existing RootScene, reused rather than recreated
	 */
	UFUNCTION()
	UActorComponent GetExistingRootByNameForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"RootScene");
	}

	/**
	 * Get the existing root by class alone for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the existing scene component, reused rather than recreated
	 */
	UFUNCTION()
	UActorComponent GetExistingRootByClassForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass());
	}

	/**
	 * Lazily create a named scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the newly created LazyScene component
	 */
	UFUNCTION()
	USceneComponent CreateLazySceneForCpp()
	{
		return Cast<USceneComponent>(GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene"));
	}

	/**
	 * Look up the lazily created scene again, which must reuse it.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the same LazyScene component rather than a second one
	 */
	UFUNCTION()
	UActorComponent GetLazySceneAgainForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyScene");
	}

	/**
	 * Lazily create a named billboard component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the newly created LazyBillboard component
	 */
	UFUNCTION()
	UBillboardComponent CreateLazyBillboardForCpp()
	{
		return Cast<UBillboardComponent>(GetOrCreateComponent(UBillboardComponent::StaticClass(), n"LazyBillboard"));
	}

	/**
	 * Look up the lazy billboard through a parent class for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs none
	 * @Return the LazyBillboard component found as a USceneComponent
	 */
	UFUNCTION()
	UActorComponent GetLazyBillboardBySceneClassForCpp()
	{
		return GetOrCreateComponent(USceneComponent::StaticClass(), n"LazyBillboard");
	}

	/**
	 * Observe that a locally constructed actor has no root component.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs an actor that has not been spawned
	 * @Return true when RootScene is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		return RootScene == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null root.
	 *
	 * @Kind Observe
	 * @Covers Component.GetOrCreateComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when both roots are null
	 * @Param Second the other actor, also expected to hold a null root
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorGetOrCreateComponent Second)
	{
		if (Second is null)
		{
			throw("GetOrCreateComponent setup: required Second is null");
		}
		if (RootScene != nullptr)
		{
			return false;
		}
		return Second.RootScene == nullptr;
	}
}
/** @end */
