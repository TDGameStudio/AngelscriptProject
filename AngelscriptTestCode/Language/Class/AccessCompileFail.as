/**
 * @version v1
 * @summary Access forms that do not compile.
 * @topic Language
 * @topic Class
 *
 * invalid-private-field-from-outside      // A private field cannot be read from a free function.
 * invalid-protected-field-from-outside    // A protected field cannot be read from a free function.
 */
/**
 * @begin invalid-private-field-from-outside
 * @summary A private field cannot be read from a free function.
 * @topic Negative
 */
class AHolder
{
	private int Secret;
}

int Test()
{
	AHolder Object;
	return Object.Secret;
}
/** @end */
/**
 * @begin invalid-protected-field-from-outside
 * @summary A protected field cannot be read from a free function.
 * @topic Negative
 */
class AHolder
{
	protected int Secret;
}

int Test()
{
	AHolder Object;
	return Object.Secret;
}
/** @end */
