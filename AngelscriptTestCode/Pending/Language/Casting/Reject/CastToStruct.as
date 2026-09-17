/**
 * @version v1
 * @summary Casting to a struct is rejected: the template argument must be an object-derived class. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting to a struct is rejected: the template argument must be an object-derived class. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test(AActor A)
{
	auto X = Cast<FVector>(A);
}
/** @end */
