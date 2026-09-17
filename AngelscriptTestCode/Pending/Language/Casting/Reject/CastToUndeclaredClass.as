/**
 * @version v1
 * @summary Casting to a class that was never declared is rejected: the template argument must name a type that exists. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting to a class that was never declared is rejected: the template argument must name a type that exists. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test(AActor A)
{
	auto X = Cast<NonExistentClass>(A);
}
/** @end */
