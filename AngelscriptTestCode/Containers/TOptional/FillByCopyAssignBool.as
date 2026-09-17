/**
 * @version v1
 * @summary An &out TOptional<bool> is filled by copy assignment.
 * @topic Containers
 *
 * FillByCopyAssignBool
 */
/**
 * @begin FillByCopyAssignBool
 * @summary An &out TOptional<bool> is filled by copy assignment.
 * @topic Containers
 */
void FillByCopyAssignBool(TOptional<bool>&out Result)
{
	TOptional<bool> Source;
	Source.Set(true);
	Result = Source;
}
/** @end */
