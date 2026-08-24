// Theme: Containers.TMap. Positive TMap bracket access.
// C++ AssertCompiles ASSyntaxCon_MapAccess. Oracle: after Add("key", 42), Map["key"]==42.
// Extra: empty Num 0; two maps stay independent after overwrite. DefaultSafe.

void Test()
{
	TMap<FString, int> Map;
	Map.Add("key", 42);
	int Val = Map["key"];
}

int Observe_TMapAccess_Nominal()
{
	TMap<FString, int> Map;
	Map.Add("key", 42);
	int Val = Map["key"];
	return Val;
}

int Observe_TMapAccess_EmptyDefault()
{
	TMap<FString, int> Map;
	return Map.Num();
}

bool Observe_TMapAccess_CopyIndependence()
{
	TMap<FString, int> First;
	TMap<FString, int> Second;
	First.Add("key", 42);
	Second.Add("key", 42);
	First.Add("key", 7);
	int FirstVal = First["key"];
	int SecondVal = Second["key"];
	return FirstVal == 7 && SecondVal == 42;
}
