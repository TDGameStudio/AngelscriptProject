/**
 * @version v1
 * @summary Copy assignment copies bool members and stays independent of the source.
 * @topic Containers
 *
 * CopyAssignBool
 */
/**
 * @begin CopyAssignBool
 * @summary Copy assignment copies bool members and stays independent of the source.
 * @topic Containers
 */
bool CopyAssignBool()
{
	TSet<bool> Other;
	Other.Add(true);
	Other.Add(false);
	TSet<bool> Values;
	Values.Add(true);
	Values = Other;
	return Values.Num() == 2
		&& Values.Contains(true)
		&& Values.Contains(false)
		&& Other.Num() == 2;
}
/** @end */
