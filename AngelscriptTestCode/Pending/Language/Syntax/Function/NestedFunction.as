/**
 * @version v1
 * @summary A function cannot be declared inside another function.
 * @topic Language
 */
/**
 * @version root
 * @summary A function cannot be declared inside another function.
 * @topic Negative
 */
void Outer()
{
	void Inner()
	{
	}
}
/** @end */
