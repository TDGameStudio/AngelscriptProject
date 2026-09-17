/**
 * @version v1
 * @summary A range-for whose loop variable type does not match the container's element type is rejected. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A range-for whose loop variable type does not match the container's element type is rejected. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	TArray<int> Arr;
	for (FString Val : Arr)
	{
	}
}
/** @end */
