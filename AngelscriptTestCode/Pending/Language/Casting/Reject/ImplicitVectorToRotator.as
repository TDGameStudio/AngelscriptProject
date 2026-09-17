/**
 * @version v1
 * @summary Assigning an FVector to an FRotator is rejected: the two structs are distinct types even though both hold three floats. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning an FVector to an FRotator is rejected: the two structs are distinct types even though both hold three floats. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	FVector V = FVector(1, 0, 0);
	FRotator R = V;
}
/** @end */
