/**
 * @version v1
 * @summary Copy assignment copies FString members and stays independent of later source mutation.
 * @topic Containers
 *
 * CopyAssignFString
 */
/**
 * @begin CopyAssignFString
 * @summary Copy assignment copies FString members and stays independent of later source mutation.
 * @topic Containers
 */
bool CopyAssignFString()
{
	TSet<FString> Other;
	Other.Add("alpha");
	Other.Add("beta");
	TSet<FString> Values;
	Values = Other;
	Other.Add("gamma");
	return Values.Num() == 2
		&& Values.Contains("alpha")
		&& Values.Contains("beta")
		&& !Values.Contains("gamma")
		&& Other.Num() == 3;
}
/** @end */
