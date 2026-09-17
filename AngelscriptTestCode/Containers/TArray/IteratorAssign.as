/**
 * @version v1
 * @summary Assigning one iterator onto another copies CanProceed from the source iterator.
 * @topic Containers
 *
 * IteratorAssign
 */
/**
 * @begin IteratorAssign
 * @summary Assigning one iterator onto another copies CanProceed from the source iterator.
 * @topic Containers
 */
bool IteratorAssign()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	TArrayIterator<int32> Iterator;
	TArrayIterator<int32> Other = Values.Iterator();
	Iterator = Other;
	const TArray<int32> ConstValues = Values;
	TArrayConstIterator<int32> ConstIterator;
	TArrayConstIterator<int32> ConstOther = ConstValues.Iterator();
	ConstIterator = ConstOther;
	return Iterator.CanProceed && Other.CanProceed && ConstIterator.CanProceed && ConstOther.CanProceed;
}
/** @end */
