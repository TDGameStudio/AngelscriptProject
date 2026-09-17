/**
 * @version v1
 * @summary An &out TArray<int32> is filled by assigning a local source array.
 * @topic Containers
 *
 * FillByCopyAssign
 */
/**
 * @begin FillByCopyAssign
 * @summary An &out TArray<int32> is filled by assigning a local source array.
 * @topic Containers
 */
void FillByCopyAssign(TArray<int32>&out Result)
{
	TArray<int32> Source;
	Source.Add(1);
	Source.Add(2);
	Result = Source;
}
/** @end */
