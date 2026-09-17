/**
 * @version v1
 * @summary An &out TMap<FName, int> is filled by assigning a local source map.
 * @topic Containers
 *
 * FillByCopyAssignFName
 */
/**
 * @begin FillByCopyAssignFName
 * @summary An &out TMap<FName, int> is filled by assigning a local source map.
 * @topic Containers
 */
void FillByCopyAssignFName(TMap<FName, int>&out Result)
{
	TMap<FName, int> Source;
	Source.Add(n"Red", 1);
	Source.Add(n"Green", 2);
	Source.Add(n"Blue", 3);
	Result = Source;
}
/** @end */
