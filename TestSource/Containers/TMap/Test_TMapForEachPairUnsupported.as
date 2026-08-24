// Theme: Containers.TMap. NegativeDiagnostic: for-each Pair.Key/Pair.Value on TMap.
// C++ AssertFailsWithError ASCovLoop_TMapForEachPairUnsupported.
// Expected diagnostic: "'Key' is not a member of 'TMapIterator<int,int>'".
// Isolate the failing program. DiagnosticOnly.

int UnsupportedMapPair()
{
	TMap<int, int> Map;
	Map.Add(1, 10);

	int Sum = 0;
	for (auto& Pair : Map)
	{
		Sum += Pair.Key + Pair.Value;
	}
	return Sum;
}
