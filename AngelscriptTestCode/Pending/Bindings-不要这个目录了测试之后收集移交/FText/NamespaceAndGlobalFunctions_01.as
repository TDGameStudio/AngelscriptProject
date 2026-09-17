/**
 * @version v1
 * @summary Observe IdenticalTo history comparison and FText::Join overloads.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe IdenticalTo history comparison and FText::Join overloads.
 * @topic Baseline
 */
// FText FText::Join(const FText& Delimiter, const TArray<FFormatArgumentValue>& Args);
// FText FText::Join(const FText& Delimiter, const TArray<FText>& Args);
// Inputs: Two FromString("Hello") values, a different "Other", default flags
// and DeepCompare, delimiter ",", argument arrays with two entries and empty.
// Expected observations: Identical copies compare true. Different strings
// compare false. Join of two texts contains both and the delimiter. Empty
// join is empty.
// Boundary/ownership: IdenticalTo compares histories, not just display
// strings, when DeepCompare is requested.

namespace TS_FText_NamespaceAndGlobalFunctions_01
{
	bool Observe_IdenticalTo_Nominal()
	{
		FText Left = FText::FromString("Hello");
		FText Right = FText::FromString("Hello");
		FText Copied = Left;
		FText Other = FText::FromString("Other");
		return Copied.IdenticalTo(Left) && Left.ToString() == Right.ToString() && !Left.IdenticalTo(Other) && Copied.IdenticalTo(Left, ETextIdenticalModeFlags::DeepCompare) && !Left.IdenticalTo(Other, ETextIdenticalModeFlags::DeepCompare);
	}

	bool Observe_Join_Nominal()
	{
		FText Delimiter = FText::FromString(",");
		TArray<FText> Texts;
		Texts.Add(FText::FromString("a"));
		Texts.Add(FText::FromString("b"));
		FText JoinedTexts = FText::Join(Delimiter, Texts);
		TArray<FText> EmptyTexts;
		FText EmptyJoined = FText::Join(Delimiter, EmptyTexts);

		TArray<FFormatArgumentValue> Args;
		Args.Add(FFormatArgumentValue(FText::FromString("x")));
		Args.Add(FFormatArgumentValue(7));
		FText JoinedArgs = FText::Join(Delimiter, Args);

		return JoinedTexts.ToString().Contains("a") && JoinedTexts.ToString().Contains(",") && EmptyJoined.IsEmpty() && JoinedArgs.ToString().Len() > 0;
	}
}
/** @end */
