/**
 * @version v1
 * @summary An &out TArray<FString> is filled then walked with an iterator.
 * @topic Containers
 *
 * FillByConstIteratorWalkFString
 */
/**
 * @begin FillByConstIteratorWalkFString
 * @summary An &out TArray<FString> is filled then walked with an iterator.
 * @topic Containers
 */
void FillByConstIteratorWalkFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	TArrayIterator<FString> Iterator = Result.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
