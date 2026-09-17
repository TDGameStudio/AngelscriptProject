/**
 * @version v1
 * @summary An &out TOptional<int32> is filled by copy assignment.
 * @topic Containers
 *
 * FillByCopyAssign
 */
/**
 * @begin FillByCopyAssign
 * @summary An &out TOptional<int32> is filled by copy assignment.
 * @topic Containers
 */
void FillByCopyAssign(TOptional<int32>&out Result)
{
	TOptional<int32> Source;
	Source.Set(7);
	Result = Source;
}
/** @end */
