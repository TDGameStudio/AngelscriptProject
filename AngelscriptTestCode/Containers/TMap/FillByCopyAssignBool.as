/**
 * @version v1
 * @summary An &out TMap<int, bool> is filled by assigning a local source map.
 * @topic Containers
 *
 * FillByCopyAssignBool
 */
/**
 * @begin FillByCopyAssignBool
 * @summary An &out TMap<int, bool> is filled by assigning a local source map.
 * @topic Containers
 */
void FillByCopyAssignBool(TMap<int, bool>&out Result)
{
	TMap<int, bool> Source;
	Source.Add(1, true);
	Source.Add(2, false);
	Source.Add(3, true);
	Result = Source;
}
/** @end */
