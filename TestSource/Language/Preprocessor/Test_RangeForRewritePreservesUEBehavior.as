// Theme: Language.Preprocessor. Positive range-for rewrite; string/comment loops stay literal.
// C++: AngelscriptPreprocessorRangeForTests.cpp::RangeForRewritePreservesUEBehavior
// sha256=fc93cb92f107de1a36c03a8920cebc7d46e4f7e7a4cf1663822ad3c9de6813d5; lines 33-54.
// Oracle: Iterate walks Values and Lookup then a C-style loop; Preserved keeps "for (int Fake : Values)".
// Extra: empty containers are a no-op walk. DefaultSafe.

void Iterate(TArray<int>& Values, TMap<FString, int>& Lookup)
{
	FString Preserved = "for (int Fake : Values)";
	// for (int Commented : Values) {}

	for (int Value : Values)
	{
		Print(f"{Value}");
	}

	for (auto Element : Lookup)
	{
		Print(Element.GetKey());
	}

	for (int Index = 0; Index < 1; ++Index)
	{
		Print(f"{Index}");
	}
}

int Observe_Iterate_EmptyDefault()
{
	TArray<int> Values;
	TMap<FString, int> Lookup;
	Iterate(Values, Lookup);
	return Values.Num() + Lookup.Num();
}

int Observe_Iterate_Nominal()
{
	TArray<int> Values;
	Values.Add(1);
	Values.Add(2);
	TMap<FString, int> Lookup;
	Lookup.Add("A", 3);
	Iterate(Values, Lookup);
	return Values.Num() + Lookup.Num();
}

int Observe_Iterate_CopyIndependence()
{
	TArray<int> Values;
	Values.Add(4);
	TArray<int> Copy = Values;
	TMap<FString, int> Lookup;
	Iterate(Values, Lookup);
	return Copy.Num() == 1 && Copy[0] == 4 ? Values.Num() : 0;
}
