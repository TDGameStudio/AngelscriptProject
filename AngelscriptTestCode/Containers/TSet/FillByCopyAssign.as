/**
 * @version v1
 * @summary An &out TSet<int32> is filled by assigning a local source set.
 * @topic Containers
 *
 * FillByCopyAssign
 */
/**
 * @begin FillByCopyAssign
 * @summary An &out TSet<int32> is filled by assigning a local source set.
 * @topic Containers
 */
void FillByCopyAssign(TSet<int32>&out Result)
{
	TSet<int32> Source;
	Source.Add(1);
	Source.Add(2);
	Result = Source;
}
/** @end */
