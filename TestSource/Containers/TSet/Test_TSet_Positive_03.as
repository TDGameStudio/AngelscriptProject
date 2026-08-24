// Theme: Containers.TSet. Positive: TSet<FString> Contains after Add.
// C++: AngelscriptSyntaxContainerTests.cpp::TSet_Positive AssertCompiles ASSyntaxCon_SetContains.
// Oracle: Contains("hello") true after Add. Extra: empty Contains false; copy stays independent.
// DefaultSafe. Source owns locals.

void Test()
{
	TSet<FString> S;
	S.Add("hello");
	bool B = S.Contains("hello");
}

bool Observe_TSetContains_Nominal()
{
	TSet<FString> S;
	S.Add("hello");
	return S.Contains("hello");
}

bool Observe_TSetContains_EmptyDefault()
{
	TSet<FString> S;
	return S.Contains("hello") == false;
}

bool Observe_TSetContains_CopyIndependence()
{
	TSet<FString> First;
	TSet<FString> Second;
	First.Add("hello");
	return First.Contains("hello") && Second.Contains("hello") == false;
}
