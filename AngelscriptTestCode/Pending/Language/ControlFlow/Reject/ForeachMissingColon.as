/**
 * @version v1
 * @summary A range-for without the colon between the loop variable and the container is rejected. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary A range-for without the colon between the loop variable and the container is rejected. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	TArray<int> Arr;
	for (int Val Arr)
	{
	}
}
/** @end */
