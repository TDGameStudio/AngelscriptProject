/**
 * Reload pair fixed full-reload source: the corrected UCLASS publishes Value
 * default 3.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.FixingRejectedReloadFixed
 * @Harness UClass
 * @Tag Definitions.UClass.FixingRejectedReloadFixed
 * @Provenance Theme: Definitions.UClass. Reload version pair 03 (fixed full reload). CSV NegativeDiagnostic is wrong;
 * @Provenance C++ CompileModuleWithResult FullReload succeeds and publishes the corrected class.
 * @Provenance C++: AngelscriptClassGeneratorNameConflictTests.cpp::FixingRejectedReloadPublishesCorrectedClass FixedSource.
 * @Provenance Oracle: Value defaults to 3. Retained: UClassGeneratorNameConflictRecovery UCLASS. Replaced vs 02: USTRUCT -> UCLASS, Value 2 -> 3.
 * @Provenance Extra: unset handle is null; mutating one instance does not write the other.
 * @Provenance FixtureIsolated. Object handles are runner-owned when non-null.
 */

UCLASS()
class UClassGeneratorNameConflictRecovery : UObject
{
	UPROPERTY()
	int Value = 3;

	/**
	 * Observe the fixed Value default.
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
	 * Observe that writing this object leaves another at 3.
	 *
	 * @Kind Observe
	 * @Covers UClass.Reload
	 * @Param Second Other object expected to stay at 3
	 * @Inputs this.Value set to 0
	 * @Return true when Second.Value is 3
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UClassGeneratorNameConflictRecovery Second)
	{
		if (Second is null)
		{
			throw("FixingRejectedReloadFixed setup: required Second is null");
		}
		Value = 0;
		return Second.Value == 3;
	}
}
