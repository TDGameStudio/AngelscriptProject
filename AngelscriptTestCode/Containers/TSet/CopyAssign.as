/**
 * @version v1
 * @summary Copy assignment copies members and stays independent of later source mutation.
 * @topic Containers
 *
 * CopyAssign
 */
/**
 * @begin CopyAssign
 * @summary Copy assignment copies members and stays independent of later source mutation.
 * @topic Containers
 */
bool CopyAssign()
{
	TSet<int32> Other;
	Other.Add(1);
	Other.Add(2);
	TSet<int32> Values;
	Values = Other;
	Other.Add(3);
	return Values.Num() == 2
		&& Values.Contains(1)
		&& Values.Contains(2)
		&& !Values.Contains(3)
		&& Other.Num() == 3;
}
/** @end */
