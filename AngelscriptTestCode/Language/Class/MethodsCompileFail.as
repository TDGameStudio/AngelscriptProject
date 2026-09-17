/**
 * @version v1
 * @summary Method forms that do not compile.
 * @topic Language
 * @topic Class
 *
 * invalid-unknown-method    // Calling a method that the class does not declare is rejected.
 */
/**
 * @begin invalid-unknown-method
 * @summary Calling a method that the class does not declare is rejected.
 * @topic Negative
 */
class AHolder
{
	int Value;
}

int Test()
{
	AHolder Object;
	return Object.Missing();
}
/** @end */
