/**
 * @version v1
 * @summary SetNumZeroed is not valid for FString.
 * @topic Containers
 *
 * SetNumZeroedNonPrimitive
 */
/**
 * @begin SetNumZeroedNonPrimitive
 * @summary SetNumZeroed is not valid for FString.
 * @topic Containers
 */
void SetNumZeroedNonPrimitive()
{
	TArray<FString> Values;
	Values.SetNumZeroed(2);
}
/** @end */
