/**
 * @version v1
 * @summary An &inout TArray<UObject> is walked in place with an iterator.
 * @topic Containers
 *
 * MutateConstIteratorWalkUObject
 */
/**
 * @begin MutateConstIteratorWalkUObject
 * @summary An &inout TArray<UObject> is walked in place with an iterator.
 * @topic Containers
 */
void MutateConstIteratorWalkUObject(TArray<UObject>&inout Values)
{
	TArrayIterator<UObject> Iterator = Values.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
