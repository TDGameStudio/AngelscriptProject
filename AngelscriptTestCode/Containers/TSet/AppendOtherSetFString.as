/**
 * @version v1
 * @summary Append unions another FString set and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherSetFString
 */
/**
 * @begin AppendOtherSetFString
 * @summary Append unions another FString set and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherSetFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	TSet<FString> Other;
	Other.Add("gamma");
	Other.Add("delta");
	Values.Append(Other);
	return Values.Num() == 3
		&& Values.Contains("alpha")
		&& Values.Contains("gamma")
		&& Values.Contains("delta")
		&& Other.Num() == 2;
}
/** @end */
