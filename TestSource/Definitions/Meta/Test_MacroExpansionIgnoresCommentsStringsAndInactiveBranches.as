// Theme: Definitions.Meta. WorldStory: commented UPROPERTY / string literals / inactive #if COOK_COMMANDLET are not macros.
// C++: AngelscriptCoverageMacrosTests.cpp::MacroExpansionIgnoresCommentsStringsAndInactiveBranches
// Oracle: GetLiteralLength() == 32. Extra: empty LiteralMacroText length 0. FixtureIsolated.

UCLASS()
class ACoverageMacrosExpansionBoundaryActor : AActor
{
	// UPROPERTY()
	// int CommentOnlyProperty = -1;

	UPROPERTY()
	FString LiteralMacroText = "UFUNCTION() int ShouldNotExist()";

	#if COOK_COMMANDLET
	UPROPERTY()
	int CookOnlyProperty = -2;
	#endif

	UFUNCTION()
	int GetLiteralLength() const
	{
		return LiteralMacroText.Len();
	}
}

int Observe_MacroExpansion_LiteralLength(ACoverageMacrosExpansionBoundaryActor Actor)
{
	return Actor.GetLiteralLength();
}

int Observe_MacroExpansion_EmptyLiteralBoundary(ACoverageMacrosExpansionBoundaryActor Actor)
{
	Actor.LiteralMacroText = "";
	return Actor.GetLiteralLength();
}

int Observe_MacroExpansion_EmptyDefaultIsNull()
{
	ACoverageMacrosExpansionBoundaryActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
