/**
 * @version v1
 * @summary UCLASS, UENUM and UMETA preprocessor macro shapes. Alpha is the default enumerator and Beta is the next value. An unset abstract carrier handle stays null.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UCLASS, UENUM and UMETA preprocessor macro shapes. Alpha is the default enumerator and Beta is the next value. An unset abstract carrier handle stays null.
 * @topic Baseline
 */
UENUM(BlueprintType)
enum class EMacroState : uint8
{
	// Alpha Friendly
	Alpha,
	Beta UMETA(DisplayName="Beta Friendly"),
};

UCLASS(Abstract, BlueprintType)
class UMacroCarrier : UObject
{
	/**
	 * Observe that Alpha is the default enumerator.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClassEnumMetaShapes
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	int AlphaDefault()
	{
		return int(EMacroState::Alpha);
	}

	/**
	 * Observe that Beta is the next enumerator.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClassEnumMetaShapes
	 * @Inputs none
	 * @Return 1
	 * @Boundary next enumerator
	 */
	UFUNCTION()
	int BetaBoundary()
	{
		return int(EMacroState::Beta);
	}

	/**
	 * Observe that an unset abstract carrier handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClassEnumMetaShapes
	 * @Inputs an unset carrier handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		UMacroCarrier Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
