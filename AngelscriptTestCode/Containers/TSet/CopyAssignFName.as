/**
 * @version v1
 * @summary Copy assignment copies FName members and stays independent of later source mutation.
 * @topic Containers
 *
 * CopyAssignFName
 */
/**
 * @begin CopyAssignFName
 * @summary Copy assignment copies FName members and stays independent of later source mutation.
 * @topic Containers
 */
bool CopyAssignFName()
{
	TSet<FName> Other;
	Other.Add(n"Red");
	Other.Add(n"Green");
	TSet<FName> Values;
	Values = Other;
	Other.Add(n"Blue");
	return Values.Num() == 2
		&& Values.Contains(n"Red")
		&& Values.Contains(n"Green")
		&& !Values.Contains(n"Blue")
		&& Other.Num() == 3;
}
/** @end */
