/**
 * HideCategories="Rendering" publishes HideCategories metadata. The generated
 * UHideCategoriesTestObj exists; Value defaults to 0 and assigned values are
 * copy-independent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.HideCategoriesClassSpecifierSetsMeta
 * @Harness UClass
 * @Tag Definitions.UClass.HideCategoriesClassSpecifierSetsMeta
 * @Provenance Theme: Definitions.UClass. Positive HideCategories="Rendering" specifier.
 * @Provenance C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::HideCategoriesClassSpecifierSetsMeta
 * @Provenance compiles then HideCategories metadata. Oracle: generated UHideCategoriesTestObj exists; Value default 0.
 * @Provenance Extra: unset handle is null; assigned Value is copy-independent. DefaultSafe.
 */

UCLASS(HideCategories = "Rendering")
class UHideCategoriesTestObj : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UHideCategoriesTestObj handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UHideCategoriesTestObj Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed UHideCategoriesTestObj
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
	bool CopyIndependence(UHideCategoriesTestObj Second)
	{
		if (Second is null)
		{
			throw("HideCategoriesClassSpecifierSetsMeta setup: required Second is null");
		}
		Value = 9;
		if (Value != 9)
		{
			return false;
		}
		return Second.Value == 0;
	}
}
