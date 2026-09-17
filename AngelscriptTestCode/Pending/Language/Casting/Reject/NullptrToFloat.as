/**
 * @version v1
 * @summary Assigning nullptr to a float is rejected: nullptr is a handle literal, not a numeric zero. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning nullptr to a float is rejected: nullptr is a handle literal, not a numeric zero. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	float X = nullptr;
}
/** @end */
