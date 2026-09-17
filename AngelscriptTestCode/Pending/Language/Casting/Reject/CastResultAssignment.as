/**
 * @version v1
 * @summary Assigning to a Cast result is rejected: the converted handle is not an assignable lvalue. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning to a Cast result is rejected: the converted handle is not an assignable lvalue. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test(AActor A)
{
	Cast<APawn>(A) = nullptr;
}
/** @end */
