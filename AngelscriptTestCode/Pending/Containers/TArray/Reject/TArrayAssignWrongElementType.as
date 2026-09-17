/**
 * @version v1
 * @summary Assigning TArray<FString> onto TArray<int> is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Assigning TArray<FString> onto TArray<int> is rejected.
 * @topic Negative
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<int> A;
		TArray<FString> B;
		A = B;
	}
}
/** @end */
