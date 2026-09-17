/**
 * @version v1
 * @summary Reading through a namespace that was never declared is rejected. The qualified name has a namespace part that resolves to nothing.
 * @topic Language
 */
/**
 * @version root
 * @summary Reading through a namespace that was never declared is rejected. The qualified name has a namespace part that resolves to nothing.
 * @topic Negative
 */
/** */
void Test()
{
	int X = FakeNamespace::Value;
}
/** @end */
