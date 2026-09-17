/**
 * @version v1
 * @summary Assigning TArray<FString> onto TArray<int> is rejected.
 * @topic Containers
 *
 * AssignWrongElementType
 */
/**
 * @begin AssignWrongElementType
 * @summary Assigning TArray<FString> onto TArray<int> is rejected.
 * @topic Containers
 */
void AssignWrongElementType()
{
	TArray<int> A;
	TArray<FString> B;
	A = B;
}
/** @end */
