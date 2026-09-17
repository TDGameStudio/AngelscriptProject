/**
 * @version v1
 * @summary An &out TOptional<FString> is filled by copy assignment.
 * @topic Containers
 *
 * FillByCopyAssignFString
 */
/**
 * @begin FillByCopyAssignFString
 * @summary An &out TOptional<FString> is filled by copy assignment.
 * @topic Containers
 */
void FillByCopyAssignFString(TOptional<FString>&out Result)
{
	TOptional<FString> Source;
	Source.Set("alpha");
	Result = Source;
}
/** @end */
