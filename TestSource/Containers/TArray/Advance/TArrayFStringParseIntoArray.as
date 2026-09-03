/**
 * FString.ParseIntoArray writes its tokens into a TArray<FString> supplied by
 * the caller. The array is an out-parameter of a string operation, so this is
 * a composition of FString and TArray rather than a TArray method: it covers
 * the "fill a container from another API" shape that no single-method
 * Function entry expresses. Moved here from ../Function/ where it sat
 * misplaced, since the subject is the parse call and not a TArray method.
 *
 * @Theme Containers.TArray
 * @Subject TArray.ParseIntoArrayComposition
 * @Harness Advance
 * @Tag Containers.TArray.TArrayFStringParseIntoArray
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * Observe ParseIntoArray: delimiter list, keep-empty delimiter, empty source.
	 *
	 * @Kind Observe
	 * @Covers FString.ParseIntoArray
	 * @Inputs "alpha,beta;gamma|delta" with {",",";","|"}; "|middle|" keep empties; empty source
	 * @Return true when tokens match 4:beta:delta, 3:middle, and empty source yields Num 0
	 */
	UFUNCTION()
	bool ParseIntoArrayDelimiterVariants()
	{
		FString Multi = "alpha,beta;gamma|delta";
		TArray<FString> Delimiters;
		Delimiters.Add(",");
		Delimiters.Add(";");
		Delimiters.Add("|");
		TArray<FString> MultiParts;
		int MultiCount = Multi.ParseIntoArray(MultiParts, Delimiters);
		if (FString::Format("{0}:{1}:{2}", MultiCount, MultiParts[1], MultiParts[3]) != "4:beta:delta")
		{
			return false;
		}

		FString Edges = "|middle|";
		TArray<FString> EdgeParts;
		int EdgeCount = Edges.ParseIntoArray(EdgeParts, "|", false);
		if (FString::Format("{0}:{1}", EdgeCount, EdgeParts[1]) != "3:middle")
		{
			return false;
		}

		FString Empty;
		TArray<FString> EmptyParts;
		int EmptyCount = Empty.ParseIntoArray(EmptyParts, ",");
		if (EmptyCount != 0)
		{
			return false;
		}
		return EmptyParts.Num() == 0;
	}
}
