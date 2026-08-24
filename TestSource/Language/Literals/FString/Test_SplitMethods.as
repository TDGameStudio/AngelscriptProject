// Theme: Language.Literals.FString. Positive ParseIntoArray/Split/Join.
// C++: AngelscriptCoverageFStringMethodTests.cpp::SplitMethods
// sha256 from TS-LANG-0157; lines 706-771.
// Oracle: count 3; apple; cherry; left|right; 3:; lines 2; 3:Gamma; A|B|C.
// Extra: empty ParseIntoArray count 0; Join of empty array.
// DefaultSafe. Source owns locals.

int TestSplitCount()
{
	FString s = "apple,banana,cherry";
	TArray<FString> parts;
	s.ParseIntoArray(parts, ",");
	return parts.Num();
}

FString TestSplitFirst()
{
	FString s = "apple,banana,cherry";
	TArray<FString> parts;
	s.ParseIntoArray(parts, ",");
	return parts[0];
}

FString TestSplitLast()
{
	FString s = "apple,banana,cherry";
	TArray<FString> parts;
	s.ParseIntoArray(parts, ",");
	return parts[2];
}

FString TestSplitLeftRight()
{
	FString s = "left:right";
	FString left;
	FString right;
	bool bSplit = s.Split(":", left, right);
	return bSplit ? left + "|" + right : "failed";
}

FString TestParseIntoArrayKeepsEmpty()
{
	FString s = "a,,b";
	TArray<FString> parts;
	int Count = s.ParseIntoArray(parts, ",", false);
	return FString::Format("{0}:{1}", Count, parts[1]);
}

int TestParseIntoArrayLines()
{
	FString s = "Line1\nLine2\n";
	TArray<FString> parts;
	return s.ParseIntoArrayLines(parts);
}

FString TestParseIntoArrayWS()
{
	FString s = "Alpha Beta\tGamma";
	TArray<FString> parts;
	int Count = s.ParseIntoArrayWS(parts);
	return FString::Format("{0}:{1}", Count, parts[2]);
}

FString TestJoin()
{
	TArray<FString> parts;
	parts.Add("A");
	parts.Add("B");
	parts.Add("C");
	return FString::Join(parts, "|");
}

bool Observe_SplitMethods_Nominal()
{
	return TestSplitCount() == 3
		&& TestSplitFirst() == "apple"
		&& TestSplitLast() == "cherry"
		&& TestSplitLeftRight() == "left|right"
		&& TestParseIntoArrayKeepsEmpty() == "3:"
		&& TestParseIntoArrayLines() == 2
		&& TestParseIntoArrayWS() == "3:Gamma"
		&& TestJoin() == "A|B|C";
}

int Observe_ParseIntoArray_EmptyDefault()
{
	FString Empty;
	TArray<FString> parts;
	Empty.ParseIntoArray(parts, ",");
	return parts.Num();
}

FString Observe_Join_EmptyArrayBoundary()
{
	TArray<FString> parts;
	return FString::Join(parts, "|");
}
