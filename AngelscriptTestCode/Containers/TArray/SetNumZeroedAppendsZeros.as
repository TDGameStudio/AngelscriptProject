/**
 * @version v1
 * @summary SetNumZeroed appends zeros when growing and default SetNumZeroed() clears Num.
 * @topic Containers
 *
 * SetNumZeroedAppendsZeros
 */
/**
 * @begin SetNumZeroedAppendsZeros
 * @summary SetNumZeroed appends zeros when growing and default SetNumZeroed() clears Num.
 * @topic Containers
 */
bool SetNumZeroedAppendsZeros()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.SetNumZeroed(3);
	bool bGrewZeroed = Values.Num() == 3 && Values[0] == 1 && Values[1] == 0 && Values[2] == 0;
	Values.SetNumZeroed();
	return bGrewZeroed && Values.Num() == 0;
}
/** @end */
