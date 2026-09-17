/**
 * @version v1
 * @summary String index on TArray is rejected. Float index truncates and is Function, not Reject.
 * @topic Containers
 */
/**
 * @version root
 * @summary String index on TArray is rejected. Float index truncates and is Function, not Reject.
 * @topic Negative
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<int> Arr;
		Arr.Add(1);
		int X = Arr["key"];
	}
}
/** @end */
