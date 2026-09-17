/**
 * @version v1
 * @summary Passing a base handle where a derived type is expected is rejected: the narrowing direction is not implicit, so an explicit Cast is required. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Passing a base handle where a derived type is expected is rejected: the narrowing direction is not implicit, so an explicit Cast is required. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void TakePawn(APawn P)
{
}

/** */
void Test(AActor A)
{
	TakePawn(A);
}
/** @end */
