/**
 * Cyclic property dependency reload source. AddedValue defaults to 2; Other
 * properties remain null on live nodes.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.CyclicPropertyReload
 * @Harness UClass
 * @Tag Definitions.UClass.CyclicPropertyReload
 * @Provenance Theme: Definitions.UClass. Reload version pair 02 (cycle A layout change). Positive cyclic dependency.
 * @Provenance C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::CyclicPropertyDependencyTerminatesAndRetargetsBothSides ReloadSource.
 * @Provenance Oracle: AddedValue defaults to 2; Other properties remain null on live nodes.
 * @Provenance Retained: CycleA/CycleB types and Other properties. Replaced: CycleA.AddedValue = 2.
 * @Provenance Extra: AddedValue 0 is the empty boundary; mutating one CycleA does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorPropagationCycleA : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleB Other;

	UPROPERTY()
	int AddedValue = 2;

	/**
	 * Observe the AddedValue default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed CycleA
	 * @Return AddedValue
	 */
	UFUNCTION()
	int AddedValueDefault()
	{
		return AddedValue;
	}

	/**
	 * Observe writing AddedValue to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs AddedValue set to 0
	 * @Return AddedValue
	 * @Boundary zero
	 */
	UFUNCTION()
	int AddedValueEmptyBoundary()
	{
		AddedValue = 0;
		return AddedValue;
	}

	/**
	 * Observe that Other remains null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed CycleA
	 * @Return true when Other is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool OtherDefaultIsNull()
	{
		return Other == nullptr;
	}

	/**
	 * Observe that writing this node leaves another at 2.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other CycleA expected to stay at 2
	 * @Inputs this.AddedValue set to 9
	 * @Return true when Second.AddedValue is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorPropagationCycleA Second)
	{
		if (Second is null)
		{
			throw("CyclicPropertyReload setup: required Second is null");
		}
		AddedValue = 9;
		return Second.AddedValue == 2;
	}
}

UCLASS()
class UClassGeneratorPropagationCycleB : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleA Other;
}
