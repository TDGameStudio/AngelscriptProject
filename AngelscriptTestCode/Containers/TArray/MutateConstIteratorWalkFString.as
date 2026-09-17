/**
 * @version v1
 * @summary An &inout TArray<FString> is walked in place with an iterator.
 * @topic Containers
 *
 * MutateConstIteratorWalkFString
 */
/**
 * @begin MutateConstIteratorWalkFString
 * @summary An &inout TArray<FString> is walked in place with an iterator.
 * @topic Containers
 */
void MutateConstIteratorWalkFString(TArray<FString>&inout Values)
{
	TArrayIterator<FString> Iterator = Values.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
