/**
 * @version v1
 * @summary A TArrayConstIterator<bool> Proceeds through each element without mutating the array.
 * @topic Containers
 *
 * ConstIteratorWalkBool
 */
/**
 * @begin ConstIteratorWalkBool
 * @summary A TArrayConstIterator<bool> Proceeds through each element without mutating the array.
 * @topic Containers
 */
bool ConstIteratorWalkBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	const TArray<bool> ConstValues = Values;
	TArrayConstIterator<bool> ConstIterator = ConstValues.Iterator();
	const bool& First = ConstIterator.Proceed();
	const bool& Second = ConstIterator.Proceed();
	return First == false && Second == true && !ConstIterator.CanProceed;
}
/** @end */
