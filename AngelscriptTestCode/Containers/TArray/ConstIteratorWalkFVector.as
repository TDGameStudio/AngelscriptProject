/**
 * @version v1
 * @summary A TArrayConstIterator<FVector> Proceeds through each element without mutating the array.
 * @topic Containers
 *
 * ConstIteratorWalkFVector
 */
/**
 * @begin ConstIteratorWalkFVector
 * @summary A TArrayConstIterator<FVector> Proceeds through each element without mutating the array.
 * @topic Containers
 */
bool ConstIteratorWalkFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	const TArray<FVector> ConstValues = Values;
	TArrayConstIterator<FVector> ConstIterator = ConstValues.Iterator();
	const FVector& First = ConstIterator.Proceed();
	const FVector& Second = ConstIterator.Proceed();
	return First.Equals(FVector(1.0f, 0.0f, 0.0f)) && Second.Equals(FVector(0.0f, 1.0f, 0.0f)) && !ConstIterator.CanProceed;
}
/** @end */
