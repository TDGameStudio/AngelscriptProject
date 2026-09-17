/**
 * @version v1
 * @summary Iterator.Proceed throws Iterator out of bounds. after the last member.
 * @topic Containers
 *
 * IteratorProceedPastEnd
 */
/**
 * @begin IteratorProceedPastEnd
 * @summary Iterator.Proceed throws Iterator out of bounds. after the last member.
 * @topic Containers
 */
void IteratorProceedPastEnd()
{
	TSet<int> Values;
	Values.Add(10);
	TSetIterator<int> It = Values.Iterator();
	It.Proceed();
	It.Proceed();
}
/** @end */
