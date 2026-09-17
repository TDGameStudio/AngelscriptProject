/**
 * @version v1
 * @summary Observe TMap explicit iterators and Proceed aliasing for mutable and const iterators. Each function returns the exact comparison.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TMap explicit iterators and Proceed aliasing for mutable and const iterators. Each function returns the exact comparison.
 * @topic Baseline
 */
// TMapConstIterator<K,V>& TMapConstIterator<K,V>.Proceed();
// TMapIterator<K,V> TMap<K,V>.Iterator();
// TMapConstIterator<K,V> TMap<K,V>.Iterator() const;
// Inputs: Empty map, populated Alpha->1 and Beta->2, and Proceed into the
// first entry before GetKey/GetValue.
// Expected observations: Empty Iterator CanProceed is false. Populated
// Iterator CanProceed is true. Proceed returns this iterator; GetValue
// write-through is visible on Map[Key]. Const Proceed reads the same keys.
// Boundary/ownership: Create starts before the first entry; GetKey is valid
// only after Proceed. Proceed past the last entry throws.

namespace TS_TMap_IndexAndIteration_01
{
	bool Observe_Proceed_Nominal()
	{
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		Map.Add(n"Beta", 2);
		TMapIterator<FName, int32> It = Map.Iterator();
		bool bCanEnter = It.CanProceed;
		TMapIterator<FName, int32>& Alias = It.Proceed();
		const FName& Key = Alias.GetKey();
		int32& Value = Alias.GetValue();
		int32 Before = Value;
		Value = Before + 10;
		bool bAliasWroteThrough = Map[Key] == Before + 10;
		if (Alias.CanProceed)
		{
			Alias.Proceed();
		}
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> ConstIt = ConstMap.Iterator();
		TMapConstIterator<FName, int32>& ConstAlias = ConstIt.Proceed();
		const FName& ConstKey = ConstAlias.GetKey();
		const int32& ConstValue = ConstAlias.GetValue();
		return bCanEnter && Map.Contains(Key) && bAliasWroteThrough && ConstMap.Contains(ConstKey) && ConstValue == ConstMap[ConstKey];
	}

	bool Observe_Iterator_Nominal()
	{
		TMap<FName, int32> Empty;
		TMapIterator<FName, int32> EmptyIt = Empty.Iterator();
		TMap<FName, int32> Map;
		Map.Add(n"Alpha", 1);
		TMapIterator<FName, int32> It = Map.Iterator();
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> ConstIt = ConstMap.Iterator();
		return !EmptyIt.CanProceed && It.CanProceed && ConstIt.CanProceed;
	}
}
/** @end */
