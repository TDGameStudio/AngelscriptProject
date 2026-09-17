/**
 * @version v1
 * @summary Casting nullptr to a class handle is rejected even when the result is bound to a local.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting nullptr to a class handle is rejected even when the result is bound to a local.
 * @topic Negative
 */
void Test()
{
	auto X = Cast<APawn>(nullptr);
}
/** @end */
