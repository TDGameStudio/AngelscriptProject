/**
 * @version v1
 * @summary Assigning an FString to an int is rejected: string parsing is not an implicit conversion. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning an FString to an int is rejected: string parsing is not an implicit conversion. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = "5";
	int X = S;
}
/** @end */
