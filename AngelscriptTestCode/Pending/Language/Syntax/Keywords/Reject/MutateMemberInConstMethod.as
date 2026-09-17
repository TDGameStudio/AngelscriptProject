/**
 * @version v1
 * @summary A const method promises not to modify its object, so assigning a member from inside one is rejected.
 * @topic Language
 */
/**
 * @version root
 * @summary A const method promises not to modify its object, so assigning a member from inside one is rejected.
 * @topic Negative
 */
/**
 * A struct whose const method writes a member.
 *
 * @Covers Syntax.Keywords
 * @Inputs none
 * @Return does not compile
 */
struct FStructConstModify
{
	int X = 0;

	/**
	 * Attempt to assign a member from a const method.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return does not compile
	 */
	void Bad() const
	{
		X = 5;
	}
}
/** @end */
