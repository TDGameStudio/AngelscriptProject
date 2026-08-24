// Theme: Containers.TMap. Positive TMap.Contains.
// C++ AssertCompiles ASSyntaxCon_MapContains. Oracle: Contains("key") after Add is true.
// Extra: empty Contains is false; copy does not share keys. DefaultSafe.

void Test()
{
	TMap<FString, int> Map;
	Map.Add("key", 1);
	bool B = Map.Contains("key");
}

bool Observe_TMapContains_Nominal()
{
	TMap<FString, int> Map;
	Map.Add("key", 1);
	bool B = Map.Contains("key");
	return B;
}

bool Observe_TMapContains_EmptyDefault()
{
	TMap<FString, int> Map;
	return !Map.Contains("key");
}

bool Observe_TMapContains_CopyIndependence()
{
	TMap<FString, int> First;
	TMap<FString, int> Second;
	First.Add("key", 1);
	return First.Contains("key") && !Second.Contains("key");
}
