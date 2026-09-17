/**
 * @version v1
 * @summary An &out TArray<bool> is filled by assigning a local source array.
 * @topic Containers
 *
 * FillByCopyAssignBool
 */
/**
 * @begin FillByCopyAssignBool
 * @summary An &out TArray<bool> is filled by assigning a local source array.
 * @topic Containers
 */
void FillByCopyAssignBool(TArray<bool>&out Result)
{
	TArray<bool> Source;
	Source.Add(false);
	Source.Add(true);
	Result = Source;
}
/** @end */
