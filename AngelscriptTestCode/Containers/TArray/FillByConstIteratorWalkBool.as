/**
 * @version v1
 * @summary An &out TArray<bool> is filled then walked with an iterator.
 * @topic Containers
 *
 * FillByConstIteratorWalkBool
 */
/**
 * @begin FillByConstIteratorWalkBool
 * @summary An &out TArray<bool> is filled then walked with an iterator.
 * @topic Containers
 */
void FillByConstIteratorWalkBool(TArray<bool>&out Result)
{
	Result.Add(false);
	Result.Add(true);
	TArrayIterator<bool> Iterator = Result.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
