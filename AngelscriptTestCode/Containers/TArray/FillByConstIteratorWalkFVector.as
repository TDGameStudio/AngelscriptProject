/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then walked with an iterator.
 * @topic Containers
 *
 * FillByConstIteratorWalkFVector
 */
/**
 * @begin FillByConstIteratorWalkFVector
 * @summary An &out TArray<FVector> is filled then walked with an iterator.
 * @topic Containers
 */
void FillByConstIteratorWalkFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	TArrayIterator<FVector> Iterator = Result.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
