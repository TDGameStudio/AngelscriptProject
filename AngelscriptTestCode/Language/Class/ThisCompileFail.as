/**
 * @version v1
 * @summary This forms that do not compile.
 * @topic Language
 * @topic Class
 *
 * invalid-this-outside-class    // This has no referent at global scope.
 */
/**
 * @begin invalid-this-outside-class
 * @summary This has no referent at global scope.
 * @topic Negative
 */
void Test()
{
	int Value = this;
}
/** @end */
