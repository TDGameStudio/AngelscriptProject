/**
 * DefaultToInstanced sets CLASS_DefaultToInstanced. The generated
 * UInstancedTestObj exists; Value defaults to 0 and assigned values are
 * copy-independent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.DefaultToInstancedClassSpecifierSetsFlag
 * @Harness UClass
 * @Tag Definitions.UClass.DefaultToInstancedClassSpecifierSetsFlag
 * @Provenance Theme: Definitions.UClass. Positive DefaultToInstanced class specifier.
 * @Provenance C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::DefaultToInstancedClassSpecifierSetsFlag
 * @Provenance compiles then CLASS_DefaultToInstanced. Oracle: generated UInstancedTestObj exists; Value default 0.
 * @Provenance Extra: unset handle is null; assigned Value is copy-independent. DefaultSafe.
 */

UCLASS(DefaultToInstanced)
class UInstancedTestObj : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UInstancedTestObj handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UInstancedTestObj Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed UInstancedTestObj
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe that writing this object leaves another at its default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Param Second Other instance expected to stay at 0
	 * @Inputs this.Value set to 9
	 * @Return true when this holds 9 and Second holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UInstancedTestObj Second)
	{
		if (Second is null)
		{
			throw("DefaultToInstancedClassSpecifierSetsFlag setup: required Second is null");
		}
		Value = 9;
		if (Value != 9)
		{
			return false;
		}
		return Second.Value == 0;
	}
}
