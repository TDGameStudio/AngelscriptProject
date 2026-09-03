/**
 * The preprocessor default edit specifier differs for USTRUCT versus UCLASS.
 * StructValue is editable on defaults; ClassValue is not. The observers cover
 * both empty 0 defaults and that mutating a local struct copy does not alias
 * the class value.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.DefaultPropertySpecifierUsesStructSettings
 * @Harness UClass
 * @Tag Definitions.UProperty.DefaultPropertySpecifierUsesStructSettings
 * @Provenance Theme: Definitions.UProperty. Positive: preprocessor default edit specifier differs for USTRUCT vs UCLASS.
 * @Provenance C++: StructValue bEditableOnDefaults true (EditDefaultsOnly); ClassValue not editable (NotEditable).
 * @Provenance Extra: both default to 0; mutating a local copy does not alias the other. DefaultSafe.
 */

USTRUCT()
struct FStructDefaultSpecifierCarrier
{
	UPROPERTY()
	int StructValue;
}

UCLASS()
class UClassDefaultSpecifierCarrier : UObject
{
	UPROPERTY()
	int ClassValue;

	/**
	 * Observe the empty struct member default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.DefaultPropertySpecifierUsesStructSettings
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int DefaultSpecifierEmptyStructValue()
	{
		return 0;
	}

	/**
	 * Observe that writing a local StructValue leaves ClassValue at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.DefaultPropertySpecifierUsesStructSettings
	 * @Inputs local StructValue written to 4
	 * @Return 0 from ClassValue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int DefaultSpecifierEmptyClassValueIndependent()
	{
		int StructValue = 0;
		int ClassValue = 0;
		StructValue = 4;
		return ClassValue;
	}
}
