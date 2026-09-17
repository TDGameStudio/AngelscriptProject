/**
 * @version v1
 * @summary Compile-fail cases for Nested.
 * @topic Language
 * @topic Namespace
 *
 * invalid-skip-inner-qualifier
 * invalid-namespace-missing-opening-brace
 */
/**
 * @begin invalid-skip-inner-qualifier
 * @summary The outer name alone does not expose the inner function.
 * @topic Negative
 */
int Test()
{
	return Outer::Value();
}
/** @end */
/**
 * @begin invalid-namespace-missing-opening-brace
 * @summary A namespace declaration requires an opening brace.
 * @topic Negative
 */
namespace Game
	int Score()
	{
		return 1;
	}
}
/** @end */
