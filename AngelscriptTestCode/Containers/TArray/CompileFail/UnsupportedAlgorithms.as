/**
 * @version v1
 * @summary UE algorithm aliases (StableSort, Heap, predicate, Bound) are not bound.
 * @topic Containers
 *
 * UnsupportedAlgorithms
 */
/**
 * @begin UnsupportedAlgorithms
 * @summary UE algorithm aliases (StableSort, Heap, predicate, Bound) are not bound.
 * @topic Containers
 */
void UnsupportedAlgorithms()
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
/** @end */
