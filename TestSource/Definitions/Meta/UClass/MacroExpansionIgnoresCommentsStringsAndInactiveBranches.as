/**
 * Commented UPROPERTY, string literals and inactive #if COOK_COMMANDLET are not
 * macros. GetLiteralLength is 32 for the declared literal. An empty literal has
 * length 0.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
 * @Harness UClass
 * @Tag Definitions.Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
 * @Provenance Theme: Definitions.Meta. WorldStory: commented UPROPERTY / string literals / inactive #if COOK_COMMANDLET are not macros.
 * @Provenance C++: AngelscriptCoverageMacrosTests.cpp::MacroExpansionIgnoresCommentsStringsAndInactiveBranches
 * @Provenance Oracle: GetLiteralLength() == 32. Extra: empty LiteralMacroText length 0. FixtureIsolated.
 */

UCLASS()
class ACoverageMacrosExpansionBoundaryActor : AActor
{
	// UPROPERTY()
	// int CommentOnlyProperty = -1;

	UPROPERTY()
	FString LiteralMacroText = "UFUNCTION() int ShouldNotExist()";

	/**
	 * COOK_COMMANDLET is inactive here, so CookOnlyProperty is not declared.
	 *
	 * @Covers Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
	 * @Inputs the flag COOK_COMMANDLET
	 * @Return the members below are not declared in this host
	 */
#if COOK_COMMANDLET
	UPROPERTY()
	int CookOnlyProperty = -2;
#endif

	/**
	 * Return the length of the literal that looks like a macro but is only text.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
	 * @Inputs none
	 * @Return LiteralMacroText.Len()
	 */
	UFUNCTION()
	int GetLiteralLength() const
	{
		return LiteralMacroText.Len();
	}

	/**
	 * Observe the declared literal length.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
	 * @Inputs none
	 * @Return 32
	 */
	UFUNCTION()
	int LiteralLength()
	{
		return GetLiteralLength();
	}

	/**
	 * Observe that an empty literal has length 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty literal
	 */
	UFUNCTION()
	int EmptyLiteralBoundary()
	{
		LiteralMacroText = "";
		return GetLiteralLength();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.MacroExpansionIgnoresCommentsStringsAndInactiveBranches
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		ACoverageMacrosExpansionBoundaryActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
