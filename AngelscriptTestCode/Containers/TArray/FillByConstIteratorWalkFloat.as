/**
 * @version v1
 * @summary An &out TArray<float> is filled then walked with an iterator.
 * @topic Containers
 *
 * FillByConstIteratorWalkFloat
 */
/**
 * @begin FillByConstIteratorWalkFloat
 * @summary An &out TArray<float> is filled then walked with an iterator.
 * @topic Containers
 */
void FillByConstIteratorWalkFloat(TArray<float>&out Result)
{
	Result.Add(1.0f);
	Result.Add(2.0f);
	TArrayIterator<float> Iterator = Result.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
