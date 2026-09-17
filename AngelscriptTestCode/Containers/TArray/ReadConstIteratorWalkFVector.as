/**
 * @version v1
 * @summary A const&in TArray<FVector> is walked with TArrayConstIterator.
 * @topic Containers
 *
 * ReadConstIteratorWalkFVector
 */
/**
 * @begin ReadConstIteratorWalkFVector
 * @summary A const&in TArray<FVector> is walked with TArrayConstIterator.
 * @topic Containers
 */
bool ReadConstIteratorWalkFVector(const TArray<FVector>&in Values)
{
	TArrayConstIterator<FVector> ConstIterator = Values.Iterator();
	const FVector& First = ConstIterator.Proceed();
	const FVector& Second = ConstIterator.Proceed();
	return First.Equals(FVector(1.0f, 0.0f, 0.0f)) && Second.Equals(FVector(0.0f, 1.0f, 0.0f)) && !ConstIterator.CanProceed;
}
/** @end */
