// Purpose: Observe TMapConstIterator GetKey/GetValue after Proceed. Each
// function returns the exact comparison for the C++ runner.
// AS-facing API: const K& TMapConstIterator<K,V>.GetKey() const;
// const V& TMapConstIterator<K,V>.GetValue() const;
// Inputs: Const map with Alpha->1, iterator Proceed into the first entry.
// Expected observations: GetKey is Alpha. GetValue is 1. The const value
// reference matches Map[Alpha].
// Boundary/ownership: Const iterator values are read-only aliases. GetKey
// before Proceed is out of bounds.

namespace TS_TMap_Queries_02
{
	bool Observe_GetKey_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> It = ConstMap.Iterator();
		It.Proceed();
		return It.GetKey() == n"Alpha";
	}

	bool Observe_GetValue_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> It = ConstMap.Iterator();
		It.Proceed();
		const int32& Value = It.GetValue();
		const int32& Indexed = ConstMap[n"Alpha"];
		return Value == 1 && Indexed == 1;
	}
}
