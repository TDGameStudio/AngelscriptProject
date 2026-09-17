/**
 * @version v1
 * @summary UE aliases Find / FindLast / Reverse / RemoveAll are not bound. Bound search is FindIndex; bound remove-by-value is Remove. One program; the compiler reports a no-matching-signature diagnostic per call.
 * @topic Containers
 */
/**
 * @version root
 * @summary UE aliases Find / FindLast / Reverse / RemoveAll are not bound. Bound search is FindIndex; bound remove-by-value is Remove. One program; the compiler reports a no-matching-signature diagnostic per call.
 * @topic Negative
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Find(1);
		Values.FindLast(1);
		Values.Reverse();
		Values.RemoveAll(1);
	}
}
/** @end */
