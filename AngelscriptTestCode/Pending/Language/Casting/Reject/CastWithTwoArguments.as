/**
 * @version v1
 * @summary Casting with two source arguments is rejected: Cast converts one handle, so a second argument has no meaning. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting with two source arguments is rejected: Cast converts one handle, so a second argument has no meaning. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test(AActor A, AActor B)
{
	auto X = Cast<APawn>(A, B);
}
/** @end */
