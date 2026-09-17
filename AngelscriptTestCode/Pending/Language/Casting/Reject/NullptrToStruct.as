/**
 * @version v1
 * @summary Assigning nullptr to a struct is rejected: structs are value types and have no null state. This file is the illegal program itself.
 * @topic Language
 */
/**
 * @version root
 * @summary Assigning nullptr to a struct is rejected: structs are value types and have no null state. This file is the illegal program itself.
 * @topic Negative
 */
/** */
void Test()
{
	FVector V = nullptr;
}
/** @end */
