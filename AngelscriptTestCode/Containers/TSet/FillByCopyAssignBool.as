/**
 * @version v1
 * @summary An &out TSet<bool> is filled by assigning a local source set.
 * @topic Containers
 *
 * FillByCopyAssignBool
 */
/**
 * @begin FillByCopyAssignBool
 * @summary An &out TSet<bool> is filled by assigning a local source set.
 * @topic Containers
 */
void FillByCopyAssignBool(TSet<bool>&out Result)
{
	TSet<bool> Source;
	Source.Add(true);
	Source.Add(false);
	Result = Source;
}
/** @end */
