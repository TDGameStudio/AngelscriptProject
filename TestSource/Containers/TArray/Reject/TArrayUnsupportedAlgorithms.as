/**
 * UE algorithm aliases (StableSort, Heap, predicate, Bound) are not bound.
 * Bound sort is Sort. One program; the compiler reports a no-matching-signature diagnostic per call.
 *
 * @Theme Containers.TArray
 * @Subject TArray.UnsupportedAlgorithms
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayUnsupportedAlgorithms
 * @Kind CompileReject
 * @Covers TArray.StableSort
 * @Inputs TArray<int> with 1, 2; StableSort / FilterByPredicate / FindByKey / FindByPredicate / Heapify / HeapPop / HeapPush / LowerBound / UpperBound
 * @Return does not compile; "No matching signatures to 'TArray::StableSort()'" and the same form for the other names
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.StableSort();
		Values.FilterByPredicate(1);
		Values.FindByKey(1);
		Values.FindByPredicate(1);
		Values.Heapify();
		Values.HeapPop();
		Values.HeapPush(3);
		Values.LowerBound(1);
		Values.UpperBound(2);
	}
}
