/**
 * @version v1
 * @summary SetNumZeroed with a negative size throws Invalid negative Num.
 * @topic Containers
 *
 * SetNumZeroedNegative
 */
/**
 * @begin SetNumZeroedNegative
 * @summary SetNumZeroed with a negative size throws Invalid negative Num.
 * @topic Containers
 */
void SetNumZeroedNegative()
{
	TArray<int32> Values;
	Values.SetNumZeroed(-1);
}
/** @end */
