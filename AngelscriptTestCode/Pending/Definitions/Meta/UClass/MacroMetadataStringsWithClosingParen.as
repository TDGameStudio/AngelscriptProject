/**
 * @version v1
 * @summary Metadata strings may contain a closing parenthesis without truncating the specifier list. GetClosingParenText returns 7. Alpha is 0 and Beta is the next enumerator.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Metadata strings may contain a closing parenthesis without truncating the specifier list. GetClosingParenText returns 7. Alpha is 0 and Beta is the next enumerator.
 * @topic Baseline
 */
UENUM(meta=(ToolTip="Enum ) ToolTip"))
enum class ECompilerMetadataParenState : uint8
{
	Alpha UMETA(DisplayName="Alpha ) Value", ToolTip="Alpha ) ToolTip"),
	Beta
}

UCLASS(meta=(DisplayName="Do (Test)", ToolTip="Class accepts ) text"))
class UCompilerMetadataParenCarrier : UObject
{
	/**
	 * Return the constant that proves the ')' metadata string did not truncate the list.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroMetadataStringsWithClosingParen
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION(meta=(DisplayName="Run ) Now", ToolTip="Accepts ) in text"))
	int GetClosingParenText()
	{
		return 7;
	}

	/**
	 * Observe that GetClosingParenText reports 7.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroMetadataStringsWithClosingParen
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ClosingParenTextNominal()
	{
		return GetClosingParenText();
	}

	/**
	 * Observe that Alpha is the default enumerator.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroMetadataStringsWithClosingParen
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	int AlphaDefault()
	{
		return int(ECompilerMetadataParenState::Alpha);
	}

	/**
	 * Observe that Beta is the next enumerator.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroMetadataStringsWithClosingParen
	 * @Inputs none
	 * @Return 1
	 * @Boundary next enumerator
	 */
	UFUNCTION()
	int BetaBoundary()
	{
		return int(ECompilerMetadataParenState::Beta);
	}
}
/** @end */
