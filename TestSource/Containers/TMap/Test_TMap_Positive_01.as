// Theme: Containers.TMap. Positive TMap declaration.
// C++: AngelscriptSyntaxContainerTests.cpp::TMap_Positive AssertCompiles ASSyntaxCon_MapDecl.
// Oracle: empty map Num 0. Extra: adding to one copy does not fill the other; missing key
// Contains is false. DefaultSafe.

void Test()
{
	TMap<FString, int> Map;
}

int Observe_TMapDecl_EmptyDefault()
{
	TMap<FString, int> Map;
	return Map.Num();
}

bool Observe_TMapDecl_MissingKeyBoundary()
{
	TMap<FString, int> Map;
	return !Map.Contains("key");
}

bool Observe_TMapDecl_CopyIndependence()
{
	TMap<FString, int> First;
	TMap<FString, int> Second;
	First.Add("key", 1);
	return First.Num() == 1 && Second.Num() == 0;
}
