/**
 * @version v1
 * @summary A TArrayConstIterator<float> Proceeds through each element without mutating the array.
 * @topic Containers
 *
 * ConstIteratorWalkFloat
 */
/**
 * @begin ConstIteratorWalkFloat
 * @summary A TArrayConstIterator<float> Proceeds through each element without mutating the array.
 * @topic Containers
 */
bool ConstIteratorWalkFloat()
{
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	const TArray<float> ConstValues = Values;
	TArrayConstIterator<float> ConstIterator = ConstValues.Iterator();
	const float& First = ConstIterator.Proceed();
	const float& Second = ConstIterator.Proceed();
	return First == 10.0f && Second == 20.0f && !ConstIterator.CanProceed;
}
/** @end */
