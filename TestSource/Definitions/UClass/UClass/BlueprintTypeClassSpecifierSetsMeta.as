/**
 * UCLASS(BlueprintType) publishes BlueprintType meta. Value defaults to 0,
 * writing 0 stays 0, and a second instance stays independent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.BlueprintTypeClassSpecifierSetsMeta
 * @Harness UClass
 * @Tag Definitions.UClass.BlueprintTypeClassSpecifierSetsMeta
 * @Provenance Theme: Definitions.UClass. Positive: UCLASS(BlueprintType) publishes BlueprintType meta.
 * @Provenance C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::BlueprintTypeClassSpecifierSetsMeta
 * @Provenance Oracle: Value default 0; write 0 stays 0; second instance independent. DefaultSafe.
 */

UCLASS(BlueprintType)
class UBlueprintTypeTestObj : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs a freshly constructed UBlueprintTypeTestObj
	 * @Return Value
	 */
	UFUNCTION()
	int ValueDefault()
	{
		return Value;
	}

	/**
	 * Observe writing Value to 0.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs Value set to 0
	 * @Return Value
	 * @Boundary zero
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		Value = 0;
		return Value;
	}

	/**
	 * Observe that writing this object leaves another at its default.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Param Second Other instance expected to stay at 0
	 * @Inputs this.Value set to 7
	 * @Return true when this holds 7 and Second holds 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UBlueprintTypeTestObj Second)
	{
		if (Second is null)
		{
			throw("BlueprintTypeClassSpecifierSetsMeta setup: required Second is null");
		}
		Value = 7;
		if (Value != 7)
		{
			return false;
		}
		return Second.Value == 0;
	}
}
