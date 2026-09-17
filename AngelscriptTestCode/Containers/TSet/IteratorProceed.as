/**
 * @version v1
 * @summary Proceed returns each member once and then exhausts the iterator.
 * @topic Containers
 *
 * IteratorProceed
 */
/**
 * @begin IteratorProceed
 * @summary Proceed returns each member once and then exhausts the iterator.
 * @topic Containers
 */
bool IteratorProceed()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	TSetIterator<int32> It = Values.Iterator();
	bool bCanEnter = It.CanProceed;
	const int32& First = It.Proceed();
	bool bCanContinue = It.CanProceed;
	const int32& Second = It.Proceed();
	bool bExhausted = !It.CanProceed;
	return bCanEnter
		&& (First == 1 || First == 2)
		&& bCanContinue
		&& (Second == 1 || Second == 2)
		&& Second != First
		&& bExhausted;
}
/** @end */
