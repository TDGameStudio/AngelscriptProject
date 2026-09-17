/**
 * @version v1
 * @summary Observe multi-argument positional FText::Format plus named-map and ordered-array overloads.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe multi-argument positional FText::Format plus named-map and ordered-array overloads.
 * @topic Baseline
 */
// Format(Format, TMap<FString, FFormatArgumentValue>);
// Format(Format, TArray<FFormatArgumentValue>);
// Inputs: Patterns "{0}-{1}" through five placeholders, named "{Name}", array
// of two numeric arguments, and an empty map as the empty-state.
// Expected observations: Positional formats include each argument. Named
// format substitutes Name. Ordered array substitutes index 0.
// Boundary/ownership: Maps/arrays are copied into the formatter. Empty
// argument collections leave placeholders unresolved or empty.

namespace TS_FText_ConversionAndFormatting_03
{
	bool Observe_Format_Nominal()
	{
		FText Two = FText::Format(FText::FromString("{0}-{1}"), "a", 2);
		FText Three = FText::Format(FText::FromString("{0},{1},{2}"), 1, 2, 3);
		FText Four = FText::Format(FText::FromString("{0},{1},{2},{3}"), 1, 2, 3, 4);
		FText Five = FText::Format(FText::FromString("{0},{1},{2},{3},{4}"), 1, 2, 3, 4, 5);

		TMap<FString, FFormatArgumentValue> Named;
		Named.Add("Name", FFormatArgumentValue(FText::FromString("Ada")));
		FText NamedText = FText::Format(FText::FromString("{Name}"), Named);
		TMap<FString, FFormatArgumentValue> EmptyMap;
		FText EmptyNamed = FText::Format(FText::FromString("{Name}"), EmptyMap);

		TArray<FFormatArgumentValue> Ordered;
		Ordered.Add(FFormatArgumentValue(7));
		Ordered.Add(FFormatArgumentValue(8));
		FText OrderedText = FText::Format(FText::FromString("{0}-{1}"), Ordered);

		return Two.ToString().Contains("a") && Three.ToString().Contains("3") && Four.ToString().Contains("4") && Five.ToString().Contains("5") && NamedText.ToString().Contains("Ada") && OrderedText.ToString().Contains("7") && !EmptyNamed.ToString().Contains("Ada");
	}
}
/** @end */
