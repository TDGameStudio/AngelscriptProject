/**
 * @version v1
 * @summary An &inout TArray<bool> is walked in place with an iterator.
 * @topic Containers
 *
 * MutateConstIteratorWalkBool
 */
/**
 * @begin MutateConstIteratorWalkBool
 * @summary An &inout TArray<bool> is walked in place with an iterator.
 * @topic Containers
 */
void MutateConstIteratorWalkBool(TArray<bool>&inout Values)
{
	TArrayIterator<bool> Iterator = Values.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
