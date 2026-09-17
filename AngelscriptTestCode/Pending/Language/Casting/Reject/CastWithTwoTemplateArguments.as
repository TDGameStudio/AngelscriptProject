/**
 * @version v1
 * @summary Casting with two template arguments is rejected: this fork's Cast takes a single target type and infers the source. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Casting with two template arguments is rejected: this fork's Cast takes a single target type and infers the source. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test(AActor A)
{
	auto X = Cast<APawn, AActor>(A);
}
/** @end */
