/**
 * @version v1
 * @summary An &inout TArray<int32> is walked in place with an iterator.
 * @topic Containers
 *
 * MutateConstIteratorWalk
 */
/**
 * @begin MutateConstIteratorWalk
 * @summary An &inout TArray<int32> is walked in place with an iterator.
 * @topic Containers
 */
void MutateConstIteratorWalk(TArray<int32>&inout Values)
{
	TArrayIterator<int32> Iterator = Values.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
