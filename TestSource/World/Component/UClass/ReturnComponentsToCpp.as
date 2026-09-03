/**
 * Typed components and component arrays returned to C++. The entrypoint names are
 * part of the C++ contract and are kept verbatim. The observers cover the
 * local-construct default and the empty-name lookup vector.
 *
 * @Theme World.Component
 * @Subject Component.ReturnComponentsToCpp
 * @Harness UClass
 * @Tag World.Component.ReturnComponentsToCpp
 * @Provenance Theme: World.Component. WorldStory: return typed components and arrays to C++.
 * @Provenance C++: AngelscriptActorComponentTests.cpp::ReturnComponentsToCpp
 * @Provenance sha256=996595abb891e0d6e76a9daf51421711e1bbf54cadebe83bdefd34d1f7e35129; lines 817-916.
 * @Provenance Oracle ReturnBaseAForCpp / ReturnDerivedBForCpp identity. Extra: local
 * @Provenance construct stored arrays empty, BaseA/DerivedB null. FixtureIsolated.
 */

UCLASS()
class UReturnComponentBase : USceneComponent
{
}

/**
 * The derived component whose identity C++ checks separately from the base.
 *
 * @Covers Component.ReturnComponentsToCpp
 * @Inputs none
 * @Return a component derived from UReturnComponentBase
 */
UCLASS()
class UReturnComponentDerived : UReturnComponentBase
{
}

UCLASS()
class ATestActorReturnComponentsToCpp : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentBase BaseA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentBase BaseB;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentDerived DerivedA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UReturnComponentDerived DerivedB;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent BillboardA;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent BillboardB;

	UPROPERTY()
	TArray<UActorComponent> StoredBaseFamily;

	UPROPERTY()
	TArray<UActorComponent> StoredAllComponents;

	UPROPERTY()
	TArray<UActorComponent> StoredBillboards;

	/**
	 * Return the first base component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return BaseA, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnBaseAForCpp()
	{
		return BaseA;
	}

	/**
	 * Return the second derived component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return DerivedB, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnDerivedBForCpp()
	{
		return DerivedB;
	}

	/**
	 * Resolve a component by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs a component name to look up
	 * @Return the named component, or null when the name does not resolve
	 * @Param ComponentName the name to look up
	 */
	UFUNCTION()
	UActorComponent ReturnComponentByNameForCpp(FName ComponentName)
	{
		return GetComponent(UActorComponent::StaticClass(), ComponentName);
	}

	/**
	 * Create and return an explicitly named scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return the new scene component named CppExplicitNamedScene
	 */
	UFUNCTION()
	USceneComponent ReturnCreatedNamedSceneForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"CppExplicitNamedScene"));
	}

	/**
	 * Fill an array with the base component family for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an array to fill
	 * @Return every UReturnComponentBase in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void ReturnBaseFamilyArrayForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UReturnComponentBase::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with every component for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an array to fill
	 * @Return every UActorComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void ReturnAllComponentsArrayForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UActorComponent::StaticClass(), OutComponents);
	}

	/**
	 * Append the billboard components onto an array for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an array to append onto
	 * @Return the billboards appended to whatever the array already held
	 * @Param OutComponents the array to append onto
	 */
	UFUNCTION()
	void AppendBillboardArrayForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	/**
	 * Store three query results on the actor so C++ can inspect them afterwards.
	 *
	 * @Kind Action
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs none
	 * @Return StoredBaseFamily, StoredAllComponents and StoredBillboards refilled
	 */
	UFUNCTION()
	void StoreComponentArraysForCpp()
	{
		StoredBaseFamily.Empty();
		GetAllComponents(UReturnComponentBase::StaticClass(), StoredBaseFamily);

		StoredAllComponents.Empty();
		GetAllComponents(UActorComponent::StaticClass(), StoredAllComponents);

		StoredBillboards.Empty();
		GetAllComponents(UBillboardComponent::StaticClass(), StoredBillboards);
	}

	/**
	 * Observe that a locally constructed actor has stored nothing and holds no components.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an actor that has not been spawned
	 * @Return true when all three arrays are empty and all four lookups return null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (StoredBaseFamily.Num() != 0)
		{
			return false;
		}
		if (StoredAllComponents.Num() != 0)
		{
			return false;
		}
		if (StoredBillboards.Num() != 0)
		{
			return false;
		}
		if (BaseA != nullptr)
		{
			return false;
		}
		if (DerivedB != nullptr)
		{
			return false;
		}
		if (ReturnBaseAForCpp() != nullptr)
		{
			return false;
		}
		if (ReturnDerivedBForCpp() != nullptr)
		{
			return false;
		}
		return ReturnComponentByNameForCpp(n"Missing") == nullptr;
	}

	/**
	 * Observe that looking up an empty name does not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.ReturnComponentsToCpp
	 * @Inputs an unset component name
	 * @Return true when the lookup returns null
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool MissingNameNull()
	{
		return ReturnComponentByNameForCpp(n"") == nullptr;
	}
}
