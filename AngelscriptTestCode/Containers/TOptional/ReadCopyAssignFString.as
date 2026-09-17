/**
 * @version v1
 * @summary A const&in TOptional<FString> copies by assignment and compares equal.
 * @topic Containers
 *
 * ReadCopyAssignFString
 */
/**
 * @begin ReadCopyAssignFString
 * @summary A const&in TOptional<FString> copies by assignment and compares equal.
 * @topic Containers
 */
bool ReadCopyAssignFString(const TOptional<FString>&in Value)
{
	TOptional<FString> Copy;
	Copy = Value;
	TOptional<FString> Expected;
	Expected.Set("alpha");
	return Copy.IsSet() && Copy == Expected && Copy.GetValue() == "alpha";
}
/** @end */
