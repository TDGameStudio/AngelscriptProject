// Theme: Containers.TMap. Positive TMap.Num.
// C++ AssertCompiles ASSyntaxCon_MapNum. Oracle: empty Num is 0; after Add it is 1.
// Extra: two maps stay independent. DefaultSafe.

void Test()
{
	TMap<FString, int> Map;
	int N = Map.Num();
}

int Observe_TMapNum_EmptyDefault()
{
	TMap<FString, int> Map;
	int N = Map.Num();
	return N;
}

int Observe_TMapNum_AfterAddBoundary()
{
	TMap<FString, int> Map;
	Map.Add("key", 1);
	return Map.Num();
}

bool Observe_TMapNum_CopyIndependence()
{
	TMap<FString, int> First;
	TMap<FString, int> Second;
	First.Add("key", 1);
	int FirstN = First.Num();
	int SecondN = Second.Num();
	return FirstN == 1 && SecondN == 0;
}
