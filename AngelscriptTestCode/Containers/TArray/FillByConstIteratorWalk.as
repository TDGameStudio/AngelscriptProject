/**
 * @version v1
 * @summary An &out TArray<int32> is filled then walked with an iterator.
 * @topic Containers
 *
 * FillByConstIteratorWalk
 */
/**
 * @begin FillByConstIteratorWalk
 * @summary An &out TArray<int32> is filled then walked with an iterator.
 * @topic Containers
 */
void FillByConstIteratorWalk(TArray<int32>&out Result)
{
	Result.Add(1);
	Result.Add(2);
	Result.Add(3);
	TArrayIterator<int32> Iterator = Result.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
