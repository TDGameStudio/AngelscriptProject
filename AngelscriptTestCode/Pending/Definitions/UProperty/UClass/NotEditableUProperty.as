/**
 * @version v1
 * @summary A NotEditable specifier compiles. The observers cover InternalVal 0 and a non-zero boundary write that restores 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A NotEditable specifier compiles. The observers cover InternalVal 0 and a non-zero boundary write that restores 0.
 * @topic Baseline
 */
class AUPropNotEditActor : AActor
{
	UPROPERTY(NotEditable)
	int InternalVal = 0;

	/**
	 * Observe the default InternalVal of 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NotEditableUProperty
	 * @Inputs none
	 * @Return true when InternalVal is 0
	 */
	UFUNCTION()
	bool InternalValDefault()
	{
		return InternalVal == 0;
	}

	/**
	 * Observe that the empty default is 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NotEditableUProperty
	 * @Inputs none
	 * @Return true when InternalVal is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool InternalValEmptyDefault()
	{
		return InternalVal == 0;
	}

	/**
	 * Observe a boundary write of 1 that restores 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NotEditableUProperty
	 * @Inputs InternalVal written to 1 then restored
	 * @Return true when the write lands and the saved default is 0
	 * @Boundary write then restore
	 */
	UFUNCTION()
	bool InternalValBoundaryWrite()
	{
		int Saved = InternalVal;
		InternalVal = 1;
		bool bWrote = InternalVal == 1;
		InternalVal = Saved;
		if (!bWrote)
		{
			return false;
		}
		return Saved == 0;
	}
}
/** @end */
