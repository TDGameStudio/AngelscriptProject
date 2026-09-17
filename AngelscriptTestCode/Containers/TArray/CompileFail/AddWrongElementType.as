/**
 * @version v1
 * @summary Add of FString into TArray<int> is rejected.
 * @topic Containers
 *
 * AddWrongElementType
 */
/**
 * @begin AddWrongElementType
 * @summary Add of FString into TArray<int> is rejected.
 * @topic Containers
 */
void AddWrongElementType()
{
	TArray<int> Arr;
	Arr.Add("hello");
}
/** @end */
