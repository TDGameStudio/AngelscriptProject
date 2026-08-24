// Theme: Gameplay.Debug. Value oracle: guarded map/array fallbacks.
// C++: AngelscriptCoverageErrorHandlingTests.cpp::GuardedNegativeBoundariesPreserveFallbacks
// CSV NegativeDiagnostic; C++ compiles. GuardedMapMissingKey 77; GuardedMapHit 10;
// GuardedArrayInvalidIndex 31; GuardedArrayValidIndex 8.
// Extra: empty map keeps 77; empty array IsValidIndex false. DefaultSafe.

int GuardedMapMissingKey()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 10);

	int FoundValue = 77;
	if (Values.Find(FName("Missing"), FoundValue))
	{
		return FoundValue;
	}

	return FoundValue;
}

int GuardedMapHit()
{
	TMap<FName, int> Values;
	Values.Add(FName("Alpha"), 10);

	int FoundValue = 77;
	if (!Values.Find(FName("Alpha"), FoundValue))
	{
		return -1;
	}

	return FoundValue;
}

int GuardedArrayInvalidIndex()
{
	TArray<int> Values;
	Values.Add(4);
	Values.Add(8);

	if (!Values.IsValidIndex(-1))
	{
		return 31;
	}

	return Values[-1];
}

int GuardedArrayValidIndex()
{
	TArray<int> Values;
	Values.Add(4);
	Values.Add(8);

	if (!Values.IsValidIndex(1))
	{
		return -1;
	}

	return Values[1];
}

bool Observe_GuardedMapMissingKey_Nominal()
{
	return GuardedMapMissingKey() == 77;
}

bool Observe_GuardedMapHit_Nominal()
{
	return GuardedMapHit() == 10;
}

bool Observe_GuardedArrayInvalidIndex_Nominal()
{
	return GuardedArrayInvalidIndex() == 31;
}

bool Observe_GuardedArrayValidIndex_Nominal()
{
	return GuardedArrayValidIndex() == 8;
}

bool Observe_GuardedMap_EmptyDefault()
{
	TMap<FName, int> Values;
	int FoundValue = 77;
	if (Values.Find(n"Missing", FoundValue))
	{
		return FoundValue == 10;
	}
	return FoundValue == 77;
}

bool Observe_GuardedArray_EmptyDefault()
{
	TArray<int> Values;
	return Values.IsValidIndex(0) == false;
}
