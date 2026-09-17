/**
 * @version v1
 * @summary An &inout TArray<float> is walked in place with an iterator.
 * @topic Containers
 *
 * MutateConstIteratorWalkFloat
 */
/**
 * @begin MutateConstIteratorWalkFloat
 * @summary An &inout TArray<float> is walked in place with an iterator.
 * @topic Containers
 */
void MutateConstIteratorWalkFloat(TArray<float>&inout Values)
{
	TArrayIterator<float> Iterator = Values.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
