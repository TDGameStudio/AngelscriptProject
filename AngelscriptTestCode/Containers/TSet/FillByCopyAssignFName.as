/**
 * @version v1
 * @summary An &out TSet<FName> is filled by assigning a local source set.
 * @topic Containers
 *
 * FillByCopyAssignFName
 */
/**
 * @begin FillByCopyAssignFName
 * @summary An &out TSet<FName> is filled by assigning a local source set.
 * @topic Containers
 */
void FillByCopyAssignFName(TSet<FName>&out Result)
{
	TSet<FName> Source;
	Source.Add(n"Red");
	Source.Add(n"Green");
	Result = Source;
}
/** @end */
