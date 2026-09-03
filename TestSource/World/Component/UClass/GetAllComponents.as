/**
 * GetAllComponents filling and storing arrays by class. C++ calls the entrypoints
 * by name and inspects the stored arrays, so both the entrypoint names and the
 * stored-array property names are part of the contract and are kept verbatim.
 * The observers cover the local-construct default and the no-static-mesh vector.
 *
 * @Theme World.Component
 * @Subject Component.GetAllComponents
 * @Harness UClass
 * @Tag World.Component.GetAllComponents
 * @Provenance Theme: World.Component. WorldStory: GetAllComponents fill/store arrays.
 * @Provenance C++: AngelscriptActorComponentTests.cpp::GetAllComponents
 * @Provenance sha256=a42f11f164f497bcfddbf7df4cf952bab6cf3f70007a68cb3d31a85d88201880; lines 555-671.
 * @Provenance Oracle seven actor/scene components, two billboards; FillNoStaticMeshMatches empty.
 * @Provenance Extra: local construct stored arrays empty, CompA/DerivedB null.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestCompA : USceneComponent
{
}

UCLASS()
class UTestCompB : USceneComponent
{
}

/**
 * The derived component that the base-class queries must also resolve.
 *
 * @Covers Component.GetAllComponents
 * @Inputs none
 * @Return a component derived from UTestCompB
 */
UCLASS()
class UTestCompDerivedB : UTestCompB
{
}

UCLASS()
class ATestActorGetAllComponents : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestCompA CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompB CompB2;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompDerivedB DerivedB;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UTestCompDerivedB DerivedB2;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UBillboardComponent Billboard;

	UPROPERTY(DefaultComponent, Attach = CompA)
	UBillboardComponent Billboard2;

	UPROPERTY()
	TArray<UActorComponent> LastBFamilyForCpp;

	UPROPERTY()
	TArray<UActorComponent> LastAllComponentsForCpp;

	UPROPERTY()
	TArray<UActorComponent> LastBillboardsForCpp;

	/**
	 * Return the root component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs none
	 * @Return CompA, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnRootForCpp()
	{
		return CompA;
	}

	/**
	 * Return the derived component to C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs none
	 * @Return DerivedB, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent ReturnDerivedForCpp()
	{
		return DerivedB;
	}

	/**
	 * Fill an array with every actor component.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UActorComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillAllActorComponentsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UActorComponent::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with every scene component.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every USceneComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillAllSceneComponentsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(USceneComponent::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with every component of the B family, derived ones included.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UTestCompB in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillBFamilyForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UTestCompB::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with only the derived B components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UTestCompDerivedB in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillDerivedBOnlyForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UTestCompDerivedB::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with the billboard components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return every UBillboardComponent in the actor
	 * @Param OutComponents the array to fill
	 */
	UFUNCTION()
	void FillBillboardsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	/**
	 * Fill an array with static mesh components, of which the actor has none.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to fill
	 * @Return an empty array
	 * @Param OutComponents the array to fill
	 * @Boundary no matching class
	 */
	UFUNCTION()
	void FillNoStaticMeshMatchesForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UStaticMeshComponent::StaticClass(), OutComponents);
	}

	/**
	 * Append the billboard components onto an existing array.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an array to append onto
	 * @Return the billboards appended to whatever the array already held
	 * @Param OutComponents the array to append onto
	 */
	UFUNCTION()
	void AppendBillboardsForCpp(TArray<UActorComponent>&out OutComponents)
	{
		GetAllComponents(UBillboardComponent::StaticClass(), OutComponents);
	}

	/**
	 * Store three query results on the actor so C++ can inspect them afterwards.
	 *
	 * @Kind Action
	 * @Covers Component.GetAllComponents
	 * @Inputs none
	 * @Return LastBFamilyForCpp, LastAllComponentsForCpp and LastBillboardsForCpp refilled
	 */
	UFUNCTION()
	void StoreArraysForCpp()
	{
		LastBFamilyForCpp.Empty();
		GetAllComponents(UTestCompB::StaticClass(), LastBFamilyForCpp);

		LastAllComponentsForCpp.Empty();
		GetAllComponents(UActorComponent::StaticClass(), LastAllComponentsForCpp);

		LastBillboardsForCpp.Empty();
		GetAllComponents(UBillboardComponent::StaticClass(), LastBillboardsForCpp);
	}

	/**
	 * Observe that a locally constructed actor has stored nothing and holds no components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an actor that has not been spawned
	 * @Return true when all three arrays are empty and both lookups return null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (LastBFamilyForCpp.Num() != 0)
		{
			return false;
		}
		if (LastAllComponentsForCpp.Num() != 0)
		{
			return false;
		}
		if (LastBillboardsForCpp.Num() != 0)
		{
			return false;
		}
		if (CompA != nullptr)
		{
			return false;
		}
		if (DerivedB != nullptr)
		{
			return false;
		}
		if (ReturnRootForCpp() != nullptr)
		{
			return false;
		}
		return ReturnDerivedForCpp() == nullptr;
	}

	/**
	 * Observe that querying for a class the actor does not have yields nothing.
	 *
	 * @Kind Observe
	 * @Covers Component.GetAllComponents
	 * @Inputs an actor without any static mesh component
	 * @Return true when the filled array is empty
	 * @Boundary no matching class
	 */
	UFUNCTION()
	bool NoStaticMeshEmpty()
	{
		TArray<UActorComponent> OutComponents;
		FillNoStaticMeshMatchesForCpp(OutComponents);
		return OutComponents.Num() == 0;
	}
}
