/**
 * @version v1
 * @summary Members guarded by #if EDITOR are legal, unlike members guarded by an unknown flag: EDITOR is a supported condition. CSV marks the row as a negative diagnostic, but the C++ method asserts preprocessing succeeds, so this.
 * @topic Language
 */
/**
 * @version root
 * @summary Members guarded by #if EDITOR are legal, unlike members guarded by an unknown flag: EDITOR is a supported condition. CSV marks the row as a negative diagnostic, but the C++ method asserts preprocessing succeeds, so this.
 * @topic Baseline
 */
UCLASS()
class UEditorConditionalCarrier : UObject
{
	/**
	 * The accepted condition: EDITOR is a supported condition, so the members
	 * inside it are kept and preprocessing succeeds.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs the flag EDITOR
	 * @Return the members below are declared
	 */
#if EDITOR
	UPROPERTY()
	int EditorValue;

	/**
	 * Reports the editor-side value.
	 *
	 * @Covers Preprocessor.Conditionals
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int ReadEditorValue()
	{
		return 7;
	}

	/**
	 * Observe that the editor-only function reports 7.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs ReadEditorValue()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool EditorConditionalFunctionRuns()
	{
		return ReadEditorValue() == 7;
	}

	/**
	 * Observe that the editor-only property defaults to zero.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs a freshly constructed carrier
	 * @Return true when EditorValue is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool EditorConditionalPropertyDefaultsToZero()
	{
		return EditorValue == 0;
	}

	/**
	 * Observe that assigning the property leaves the function unaffected.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Conditionals
	 * @Inputs EditorValue assigned to 4, then ReadEditorValue
	 * @Return true when the property holds 4 and the function still reports 7
	 * @Boundary property independence
	 */
	UFUNCTION()
	bool EditorConditionalPropertyIsIndependent()
	{
		EditorValue = 4;

		if (ReadEditorValue() != 7)
		{
			return false;
		}

		return EditorValue == 4;
	}
#endif
}
/** @end */
