/**
 * UCLASS(Abstract) sets CLASS_Abstract. The generated object is not
 * instantiated; an unset handle is null. Value remains an exposed UPROPERTY.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.AbstractClassSpecifierSetsFlag
 * @Harness UClass
 * @Tag Definitions.UClass.AbstractClassSpecifierSetsFlag
 * @Provenance Theme: Definitions.UClass. Positive: UCLASS(Abstract) sets CLASS_Abstract.
 * @Provenance C++: AngelscriptCompilerUClassSpecifierMatrixTests.cpp::AbstractClassSpecifierSetsFlag
 * @Provenance Oracle: UAbstractTestObj is abstract; default handle is null. Extra: Value is an exposed UPROPERTY.
 * @Provenance DefaultSafe. Do not instantiate the abstract class.
 */

UCLASS(Abstract)
class UAbstractTestObj : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UAbstractTestObj handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int DefaultHandleIsNull()
	{
		UAbstractTestObj Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
