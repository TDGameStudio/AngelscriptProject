/**
 * @version v1
 * @summary Assigning nullptr to a bool is rejected: nullptr is a handle literal, not a truth value. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning nullptr to a bool is rejected: nullptr is a handle literal, not a truth value. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	bool B = nullptr;
}
/** @end */
