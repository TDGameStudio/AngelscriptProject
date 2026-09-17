/**
 * @version v1
 * @summary Casting a primitive value is rejected: Cast applies to object handles, not to numeric conversions. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting a primitive value is rejected: Cast applies to object handles, not to numeric conversions. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	int X = 5;
	auto Y = Cast<float>(X);
}
/** @end */
