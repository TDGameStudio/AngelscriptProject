/**
 * @version v1
 * @summary A TArrayConstIterator<FString> Proceeds through each element without mutating the array.
 * @topic Containers
 *
 * ConstIteratorWalkFString
 */
/**
 * @begin ConstIteratorWalkFString
 * @summary A TArrayConstIterator<FString> Proceeds through each element without mutating the array.
 * @topic Containers
 */
bool ConstIteratorWalkFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	const TArray<FString> ConstValues = Values;
	TArrayConstIterator<FString> ConstIterator = ConstValues.Iterator();
	const FString& First = ConstIterator.Proceed();
	const FString& Second = ConstIterator.Proceed();
	return First == "alpha" && Second == "beta" && !ConstIterator.CanProceed;
}
/** @end */
