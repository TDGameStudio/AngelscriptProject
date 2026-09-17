/**
 * @version v1
 * @summary Proceed yields each element in order and write-through updates the array.
 * @topic Containers
 *
 * IteratorProceed
 */
/**
 * @begin IteratorProceed
 * @summary Proceed yields each element in order and write-through updates the array.
 * @topic Containers
 */
bool IteratorProceed()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	TArrayIterator<int32> Iterator = Values.Iterator();
	int32& First = Iterator.Proceed();
	bool bFirstIsTen = First == 10;
	First = 11;
	bool bCanContinue = Iterator.CanProceed;
	int32& Second = Iterator.Proceed();
	return bFirstIsTen && Values[0] == 11 && bCanContinue && Second == 20 && !Iterator.CanProceed;
}
/** @end */
