/**
 * @version v1
 * @summary An &out TMap<int, int> is filled by assigning a local source map.
 * @topic Containers
 *
 * FillByCopyAssign
 */
/**
 * @begin FillByCopyAssign
 * @summary An &out TMap<int, int> is filled by assigning a local source map.
 * @topic Containers
 */
void FillByCopyAssign(TMap<int, int>&out Result)
{
	TMap<int, int> Source;
	Source.Add(10, 100);
	Source.Add(20, 200);
	Source.Add(30, 300);
	Result = Source;
}
/** @end */
