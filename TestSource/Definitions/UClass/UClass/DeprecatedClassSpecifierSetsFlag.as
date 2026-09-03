/**
 * Deprecated sets CLASS_Deprecated. The generated UDeprecatedTestObj exists;
 * Value defaults to 0 and assigned values are copy-independent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.DeprecatedClassSpecifierSetsFlag
 * @Harness UClass
 * @Tag Definitions.UClass.DeprecatedClassSpecifierSetsFlag
 * @Provenance Theme: Definitions.UClass. Positive Deprecated class specifier.
 * @Provenance C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::DeprecatedClassSpecifierSetsFlag
 * @Provenance compiles then CLASS_Deprecated. Oracle: generated UDeprecatedTestObj exists; Value default 0.
 * @Provenance Extra: unset handle is null; assigned Value is copy-independent. DefaultSafe.
 */

UCLASS(Deprecated)
class UDeprecatedTestObj : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UDeprecatedTestObj handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UDeprecatedTestObj Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed UDeprecatedTestObj
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
	bool CopyIndependence(UDeprecatedTestObj Second)
	{
		if (Second is null)
		{
			throw("DeprecatedClassSpecifierSetsFlag setup: required Second is null");
		}
		Value = 9;
		if (Value != 9)
		{
			return false;
		}
		return Second.Value == 0;
	}
}
