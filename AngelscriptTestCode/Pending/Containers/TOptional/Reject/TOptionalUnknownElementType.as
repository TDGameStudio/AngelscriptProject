/**
 * @version v1
 * @summary TOptional with an unknown element type is rejected; the template callback never sees a resolvable subtype.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional with an unknown element type is rejected; the template callback never sees a resolvable subtype.
 * @topic Negative
 */
namespace TOptionalTest
{
	void Test()
	{
		TOptional<FNotAType> Opt;
	}
}
/** @end */
