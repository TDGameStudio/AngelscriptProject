/**
 * @version v1
 * @summary Observe TMap/TMapIterator type declarations, copy-constructed iterators, CanProceed, and range-for value and key/value protocols. Each function returns the exact comparison for the C++ runner.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TMap/TMapIterator type declarations, copy-constructed iterators, CanProceed, and range-for value and key/value protocols. Each function returns the exact comparison for the C++ runner.
 * @topic Baseline
 */
// template<class K, class V> struct TMapIterator;
// template<class K, class V> struct TMapConstIterator;
// TMap<K,V> Map; TMapIterator<K,V> It(const TMapIterator<K,V>& Other);
// bool TMapIterator<K,V>.CanProceed;
// TMapConstIterator<K,V> It(const TMapConstIterator<K,V>& Other);
// bool TMapConstIterator<K,V>.CanProceed;
// for (auto Value : Map) { Use(Value); }
// for (auto Key, auto Value : Map) { Use(Key, Value); }
// Inputs: Empty TMap<FName,int32>, populated Alpha->1 Beta->2, copied
// iterators, and both for-range shapes.
// Expected observations: Default Map is empty. Copy-constructed iterators
// preserve CanProceed. Value for-range sums 3. Key/value for-range visits
// both names.
// Boundary/ownership: Declared template types are value types whose element
// lifetimes are owned by the map. Range-for aliases live entries.

namespace TS_TMap_Behavior_01
{
	// Default TMap<FName,int32> is empty.
	bool Observe_Surface001_Nominal()
	{
		TMap<FName, int32> Map;
		return Map.IsEmpty() && Map.Num() == 0;
	}

	// Mutable TMapIterator on a populated map CanProceed.
	bool Observe_Surface002_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> It = Map.Iterator();
		return It.CanProceed;
	}

	// Const TMapConstIterator on a populated map CanProceed.
	bool Observe_Surface003_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> It = ConstMap.Iterator();
		return It.CanProceed;
	}

	// Empty TMap specializations for FName/FString keys are empty.
	bool Observe_Surface004_Nominal()
	{
		TMap<FName, int32> Map;
		TMap<FString, int32> StringMap;
		TMap<FName, FString> NameToString;
		return Map.IsEmpty() && StringMap.IsEmpty() && NameToString.IsEmpty();
	}

	// Copy-constructed mutable iterator preserves CanProceed.
	bool Observe_It_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> Other = Map.Iterator();
		TMapIterator<FName, int32> It(Other);
		return It.CanProceed && Other.CanProceed;
	}

	// Empty mutable iterator CannotProceed; populated CanProceed.
	bool Observe_Surface024_Nominal()
	{
		TMap<FName, int32> Empty;
		TMapIterator<FName, int32> EmptyIt = Empty.Iterator();
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> It = Map.Iterator();
		return !EmptyIt.CanProceed && It.CanProceed;
	}

	// Copy-constructed const iterator CanProceed; empty const CannotProceed.
	bool Observe_Surface032_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> Other = ConstMap.Iterator();
		TMapConstIterator<FName, int32> It(Other);
		TMap<FName, int32> Empty;
		const TMap<FName, int32> ConstEmpty = Empty;
		TMapConstIterator<FName, int32> EmptyIt = ConstEmpty.Iterator();
		return It.CanProceed && !EmptyIt.CanProceed;
	}

	// Value for-range sums 3; key/value for-range visits Alpha and Beta.
	bool Observe_for_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		int32 ValueSum = 0;
		for (int32 Value : Map)
		{
			ValueSum += Value;
		}
		int32 PairCount = 0;
		int32 PairSum = 0;
		for (FName Key, int32 Value : Map)
		{
			PairCount += 1;
			PairSum += Value;
			if (Key != n"Alpha" && Key != n"Beta")
			{
				PairCount = -1;
			}
		}
		return ValueSum == 3 && PairCount == 2 && PairSum == 3;
	}
}
/** @end */
