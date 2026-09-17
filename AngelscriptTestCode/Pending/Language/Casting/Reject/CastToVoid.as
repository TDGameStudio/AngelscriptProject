/**
 * @version v1
 * @summary Cast cannot target void: void is not a type that can receive a converted value.
 * @topic Language
 */
/**
 * @version root
 * @summary Cast cannot target void: void is not a type that can receive a converted value.
 * @topic Negative
 */
void Test()
{
	int Value = 1;
	auto Result = Cast<void>(Value);
}
/** @end */
