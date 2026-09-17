/**
 * @version v1
 * @summary A const&in TArray<FString> is walked with TArrayConstIterator.
 * @topic Containers
 *
 * ReadConstIteratorWalkFString
 */
/**
 * @begin ReadConstIteratorWalkFString
 * @summary A const&in TArray<FString> is walked with TArrayConstIterator.
 * @topic Containers
 */
bool ReadConstIteratorWalkFString(const TArray<FString>&in Values)
{
	TArrayConstIterator<FString> ConstIterator = Values.Iterator();
	const FString& First = ConstIterator.Proceed();
	const FString& Second = ConstIterator.Proceed();
	return First == "alpha" && Second == "beta" && !ConstIterator.CanProceed;
}
/** @end */
