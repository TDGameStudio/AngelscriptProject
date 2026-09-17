/**
 * @version v1
 * @summary Compile-fail cases for IfNested.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-dangling-else-token           // A second else on the same if is invalid.
 * invalid-if-missing-inner-condition    // A nested if still requires a condition.
 */
/**
 * @begin invalid-dangling-else-token
 * @summary A second else on the same if is invalid.
 * @topic Negative
 */
void Test(bool Flag)
{
	if (Flag)
	{
		return;
	}
	else
	{
		return;
	}
	else
	{
		return;
	}
}
/** @end */
/**
 * @begin invalid-if-missing-inner-condition
 * @summary A nested if still requires a condition.
 * @topic Negative
 */
void Test(bool Outer)
{
	if (Outer)
	{
		if
		{
			return;
		}
	}
}
/** @end */
