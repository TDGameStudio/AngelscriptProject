/**
 * @version v1
 * @summary Observe TMap copy assignment independence and iterator assignment for mutable and const iterators. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TMap copy assignment independence and iterator assignment for mutable and const iterators. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// Other with Beta->2, and iterators from a populated map.
// Expected observations: Copy assignment copies Num and Alpha. Later Add on
// Other does not appear in Map. Assigned iterators share CanProceed on a
// populated map.
// Boundary/ownership: Assignment copies key/value pairs. Iterators alias the
// destination map, not a snapshot of Other.

namespace TS_TMap_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		TMap<FName, int32> Other;
		Other.Add(n"Alpha", 1);
		TMap<FName, int32> Map;
		Map = Other;
		bool bCopied = Map.Num() == 1 && Map.Contains(n"Alpha") && Map[n"Alpha"] == 1;
		Other.Add(n"Beta", 2);
		bool bCopyIndependent = !Map.Contains(n"Beta") && Map.Num() == 1 && Other.Num() == 2;
		TMap<FString, int32> StringOther;
		StringOther.Add("Key", 7);
		TMap<FString, int32> StringMap;
		StringMap = StringOther;
		TMapIterator<FName, int32> It;
		TMapIterator<FName, int32> OtherIt = Map.Iterator();
		It = OtherIt;
		const TMap<FName, int32> ConstMap = Map;
		TMapConstIterator<FName, int32> ConstIt;
		TMapConstIterator<FName, int32> ConstOtherIt = ConstMap.Iterator();
		ConstIt = ConstOtherIt;
		return bCopied && bCopyIndependent && StringMap.Num() == 1 && StringMap.Contains("Key") && It.CanProceed && OtherIt.CanProceed && ConstIt.CanProceed && ConstOtherIt.CanProceed;
	}
}
/** @end */
