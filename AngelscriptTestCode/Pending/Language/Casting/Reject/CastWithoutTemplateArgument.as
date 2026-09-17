/**
 * @version v1
 * @summary Casting without a template argument is rejected: the target type cannot be inferred the way auto infers a local. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting without a template argument is rejected: the target type cannot be inferred the way auto infers a local. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test(AActor A)
{
	auto X = Cast(A);
}
/** @end */
