/**
 * @version v1
 * @summary Compile-fail cases for IfElse.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-else-without-if       // An else clause cannot stand alone.
 * invalid-else-if-without-if    // Else-if cannot start a statement.
 */
/**
 * @begin invalid-else-without-if
 * @summary An else clause cannot stand alone.
 * @topic Negative
 */
void Test()
{
	else
	{
		return;
	}
}
/** @end */
/**
 * @begin invalid-else-if-without-if
 * @summary Else-if cannot start a statement.
 * @topic Negative
 */
void Test()
{
	else if (true)
	{
		return;
	}
}
/** @end */
