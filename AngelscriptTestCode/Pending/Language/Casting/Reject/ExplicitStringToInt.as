/**
 * @version v1
 * @summary Converting an FString to an int with an explicit conversion is rejected: string parsing is not a conversion constructor here. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Converting an FString to an int with an explicit conversion is rejected: string parsing is not a conversion constructor here. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	FString S = "hello";
	int X = int(S);
}
/** @end */
