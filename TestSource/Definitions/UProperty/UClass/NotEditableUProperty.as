/**
 * A NotEditable specifier compiles. The observers cover InternalVal 0 and a
 * non-zero boundary write that restores 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.NotEditableUProperty
 * @Harness UClass
 * @Tag Definitions.UProperty.NotEditableUProperty
 * @Provenance Theme: Definitions.UProperty. WorldStory: NotEditable specifier.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles
 * @Provenance UPropSP_NotEditable; lines 152-158;
 * @Provenance sha256=5d36aa6ac54cb9273a16df90c21d4ce7224a884cf4e488b8dcf717ba33f7975d.
 * @Provenance Oracle: InternalVal default is 0 on the spawned actor.
 * @Provenance Extra: 0 is the empty/default; 1 is a non-zero boundary write then restore.
 * @Provenance FixtureIsolated.
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
