/**
 * @version v1
 * @summary An &out TOptional<FName> is filled by copy assignment.
 * @topic Containers
 *
 * FillByCopyAssignFName
 */
/**
 * @begin FillByCopyAssignFName
 * @summary An &out TOptional<FName> is filled by copy assignment.
 * @topic Containers
 */
void FillByCopyAssignFName(TOptional<FName>&out Result)
{
	TOptional<FName> Source;
	Source.Set(n"Red");
	Result = Source;
}
/** @end */
