// Theme: Containers.TArray. Positive ParseIntoArray delimiter array and empty-keep.
// C++: "4:beta:delta" and Format Count:parts[1] for "|middle|".
// Extra: empty source yields empty parts when cull empties. DefaultSafe.

FString TestParseIntoArrayWithDelimiterArray()
{
	FString s = "alpha,beta;gamma|delta";
	TArray<FString> delimiters;
	delimiters.Add(",");
	delimiters.Add(";");
	delimiters.Add("|");

	TArray<FString> parts;
	int Count = s.ParseIntoArray(parts, delimiters);
	return FString::Format("{0}:{1}:{2}", Count, parts[1], parts[3]);
}

FString TestParseIntoArrayKeepsBoundaryEmptyValues()
{
	FString s = "|middle|";
	TArray<FString> parts;
	int Count = s.ParseIntoArray(parts, "|", false);
	return FString::Format("{0}:{1}", Count, parts[1]);
}

bool Observe_ParseIntoArray_Nominal()
{
	return TestParseIntoArrayWithDelimiterArray() == "4:beta:delta"
		&& TestParseIntoArrayKeepsBoundaryEmptyValues() == "3:middle";
}

bool Observe_ParseIntoArray_EmptyDefault()
{
	FString Empty;
	TArray<FString> Parts;
	int Count = Empty.ParseIntoArray(Parts, ",");
	return Count == 0 && Parts.Num() == 0;
}
