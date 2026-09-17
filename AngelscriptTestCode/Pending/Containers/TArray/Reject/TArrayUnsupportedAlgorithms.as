/**
 * @version v1
 * @summary UE algorithm aliases (StableSort, Heap, predicate, Bound) are not bound. Bound sort is Sort. One program; the compiler reports a no-matching-signature diagnostic per call.
 * @topic Containers
 */
/**
 * @version root
 * @summary UE algorithm aliases (StableSort, Heap, predicate, Bound) are not bound. Bound sort is Sort. One program; the compiler reports a no-matching-signature diagnostic per call.
 * @topic Negative
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
/** @end */
