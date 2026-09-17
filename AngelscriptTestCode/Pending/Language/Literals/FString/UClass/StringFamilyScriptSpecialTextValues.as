/**
 * @version v1
 * @summary A text member stores an escaped string built from newlines, tabs, quotes, and backslashes; a source member is grown to 1050 characters and converted to text. Both read back losslessly. The UPROPERTY names EscapedText.
 * @topic Language
 */
/**
 * @version root
 * @summary A text member stores an escaped string built from newlines, tabs, quotes, and backslashes; a source member is grown to 1050 characters and converted to text. Both read back losslessly. The UPROPERTY names EscapedText.
 * @topic Baseline
 */
UCLASS()
class ACoverageFStringSpecialTextActor : AActor
{
	UPROPERTY()
	FText EscapedText;

	UPROPERTY()
	FText LongText;

	UPROPERTY()
	FString LongTextSource;

	/**
	 * Build the escaped text and the 1050-character source during actor begin.
	 *
	 * @Covers Literals.FText
	 * @Inputs A 1050-character "t" source and an escaped FText
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EscapedText = FText::FromString("LineOne\nLineTwo\t\"Quote\"\\Slash");

		for (int i = 0; i < 1050; ++i)
		{
			LongTextSource += "t";
		}

		LongText = FText::FromString(LongTextSource);
	}

	/**
	 * Confirm the 1050-character source and its text conversion both hold.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs LongTextSource and LongText built by BeginPlay
	 * @Return true when both lengths are 1050
	 * @Boundary 1050-character length
	 */
	UFUNCTION()
	bool VerifyLongTextLengthBoundary()
	{
		if (LongTextSource.Len() != 1050)
		{
			return false;
		}
		return LongText.ToString().Len() == 1050;
	}

	/**
	 * Confirm the escaped text reads back with all escape sequences preserved.
	 *
	 * @Kind Observe
	 * @Covers Literals.FText
	 * @Inputs EscapedText built by BeginPlay
	 * @Return true when ToString preserves newline, tab, quote, and backslash
	 */
	UFUNCTION()
	bool VerifyEscapedTextRoundTrip()
	{
		return EscapedText.ToString() == "LineOne\nLineTwo\t\"Quote\"\\Slash";
	}
}
/** @end */
