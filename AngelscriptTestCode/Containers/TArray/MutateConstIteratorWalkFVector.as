/**
 * @version v1
 * @summary An &inout TArray<FVector> is walked in place with an iterator.
 * @topic Containers
 *
 * MutateConstIteratorWalkFVector
 */
/**
 * @begin MutateConstIteratorWalkFVector
 * @summary An &inout TArray<FVector> is walked in place with an iterator.
 * @topic Containers
 */
void MutateConstIteratorWalkFVector(TArray<FVector>&inout Values)
{
	TArrayIterator<FVector> Iterator = Values.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
