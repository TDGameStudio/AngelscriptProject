/**
 * @version v1
 * @summary SetNumZeroed on an empty int32 array fills both new slots with 0.
 * @topic Containers
 *
 * SetNumZeroedPrimitive
 */
/**
 * @begin SetNumZeroedPrimitive
 * @summary SetNumZeroed on an empty int32 array fills both new slots with 0.
 * @topic Containers
 */
bool SetNumZeroedPrimitive()
{
	TArray<int32> Values;
	Values.SetNumZeroed(2);
	return Values.Num() == 2 && Values[0] == 0 && Values[1] == 0;
}
/** @end */
