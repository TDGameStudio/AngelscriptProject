/**
 * @version v1
 * @summary Assigning a TArray to an int is rejected: a container has no implicit scalar value. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning a TArray to an int is rejected: a container has no implicit scalar value. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	TArray<int> Arr;
	int X = Arr;
}
/** @end */
