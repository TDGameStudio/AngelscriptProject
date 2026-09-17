/**
 * @version v1
 * @summary Initialising an FString from nullptr is rejected: a string is a value type and has no null state. This file is the illegal program itself; do not substitute an empty string, since the nullptr is the point.
 * @topic Language
 */
/**
 * @version root
 * @summary Initialising an FString from nullptr is rejected: a string is a value type and has no null state. This file is the illegal program itself; do not substitute an empty string, since the nullptr is the point.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = nullptr;
}
/** @end */
