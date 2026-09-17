/**
 * @version v1
 * @summary Copy-constructed iterators share CanProceed with the source walkers.
 * @topic Containers
 *
 * IteratorWalk
 */
/**
 * @begin IteratorWalk
 * @summary Copy-constructed iterators share CanProceed with the source walkers.
 * @topic Containers
 */
bool IteratorWalk()
{
	TArray<int32> Empty;
	TArrayIterator<int32> EmptyIt = Empty.Iterator();
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	TArrayIterator<int32> Other = Values.Iterator();
	TArrayIterator<int32> Iterator(Other);
	const TArray<int32> ConstValues = Values;
	TArrayConstIterator<int32> ConstOther = ConstValues.Iterator();
	TArrayConstIterator<int32> ConstIterator(ConstOther);
	return !EmptyIt.CanProceed && Iterator.CanProceed && Other.CanProceed && ConstIterator.CanProceed;
}
/** @end */
