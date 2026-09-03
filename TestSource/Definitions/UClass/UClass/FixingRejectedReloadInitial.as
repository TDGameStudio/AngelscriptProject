/**
 * Reload pair initial source: CompileAnnotatedModuleFromMemory publishes
 * UClassGeneratorNameConflictRecovery with Value default 1.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.FixingRejectedReloadInitial
 * @Harness UClass
 * @Tag Definitions.UClass.FixingRejectedReloadInitial
 * @Provenance Theme: Definitions.UClass. Reload version pair 01 (initial). CSV NegativeDiagnostic is wrong;
 * @Provenance C++ CompileAnnotatedModuleFromMemory succeeds and publishes the class.
 * @Provenance C++: AngelscriptClassGeneratorNameConflictTests.cpp::FixingRejectedReloadPublishesCorrectedClass InitialSource.
 * @Provenance Oracle: Value defaults to 1. Retained across the pair: UClassGeneratorNameConflictRecovery name.
 * @Provenance Extra: unset handle is null; mutating one instance does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorNameConflictRecovery : UObject
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Observe the initial Value default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs a freshly constructed object
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe that a nullptr handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Inputs UClassGeneratorNameConflictRecovery Object = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UClassGeneratorNameConflictRecovery Object = nullptr;
		return Object == nullptr;
	}

	/**
	 * Observe that writing this object leaves another at 1.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other object expected to stay at 1
	 * @Inputs this.Value set to 0
	 * @Return true when Second.Value is 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorNameConflictRecovery Second)
	{
		if (Second is null)
		{
			throw("FixingRejectedReloadInitial setup: required Second is null");
		}
		Value = 0;
		return Second.Value == 1;
	}
}
