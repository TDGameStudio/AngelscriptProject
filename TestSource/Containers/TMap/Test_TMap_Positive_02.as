// Theme: Containers.TMap. Positive TMap.Add.
// C++ AssertCompiles ASSyntaxCon_MapAdd. Oracle: Add("key", 42) then ["key"]==42.
// Extra: empty Num 0; overwrite same key; two maps stay independent. DefaultSafe.

void Test()
{
	TMap<FString, int> Map;
	Map.Add("key", 42);
}

int Observe_TMapAdd_Nominal()
{
	TMap<FString, int> Map;
	Map.Add("key", 42);
	return Map["key"];
}

int Observe_TMapAdd_EmptyDefault()
{
	TMap<FString, int> Map;
	return Map.Num();
}

int Observe_TMapAdd_OverwriteBoundary()
{
	TMap<FString, int> Map;
	Map.Add("key", 42);
	Map.Add("key", 1);
	return Map["key"];
}

bool Observe_TMapAdd_CopyIndependence()
{
	TMap<FString, int> First;
	TMap<FString, int> Second;
	First.Add("key", 42);
	Second.Add("key", 42);
	First.Add("key", 1);
	return First["key"] == 1 && Second["key"] == 42;
}
