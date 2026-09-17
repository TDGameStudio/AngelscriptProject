/**
 * @version v1
 * @summary Append unions another bool set and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherSetBool
 */
/**
 * @begin AppendOtherSetBool
 * @summary Append unions another bool set and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherSetBool()
{
	TSet<bool> Values;
	Values.Add(true);
	TSet<bool> Other;
	Other.Add(false);
	Values.Append(Other);
	return Values.Num() == 2
		&& Values.Contains(true)
		&& Values.Contains(false)
		&& Other.Num() == 1;
}
/** @end */
