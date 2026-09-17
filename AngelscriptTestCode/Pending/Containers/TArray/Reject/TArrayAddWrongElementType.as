/**
 * @version v1
 * @summary Add of FString into TArray<int> is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add of FString into TArray<int> is rejected.
 * @topic Negative
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<int> Arr;
		Arr.Add("hello");
	}
}
/** @end */
