/**
 * @version v1
 * @summary Compile-fail cases for DefiniteAssignment.
 * @topic Language
 * @topic Operators
 *
 * invalid-unassigned-read
 */
/**
 * @begin invalid-unassigned-read
 * @summary Reading a local that is not definitely assigned is invalid.
 * @topic Negative
 */
int Test(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	return X;
}
/** @end */
