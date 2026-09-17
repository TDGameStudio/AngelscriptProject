/**
 * @version v1
 * @summary A const iterator Proceeds through each element without mutating the array.
 * @topic Containers
 *
 * ConstIteratorWalk
 */
/**
 * @begin ConstIteratorWalk
 * @summary A const iterator Proceeds through each element without mutating the array.
 * @topic Containers
 */
bool ConstIteratorWalk()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	const TArray<int32> ConstValues = Values;
	TArrayConstIterator<int32> ConstIterator = ConstValues.Iterator();
	const int32& First = ConstIterator.Proceed();
	const int32& Second = ConstIterator.Proceed();
	return First == 10 && Second == 20 && !ConstIterator.CanProceed;
}
/** @end */
