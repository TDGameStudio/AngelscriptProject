/**
 * @version v1
 * @summary Append unions another set and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherSet
 */
/**
 * @begin AppendOtherSet
 * @summary Append unions another set and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherSet()
{
	TSet<int32> Values;
	Values.Add(1);
	TSet<int32> Other;
	Other.Add(3);
	Other.Add(4);
	Values.Append(Other);
	return Values.Num() == 3
		&& Values.Contains(1)
		&& Values.Contains(3)
		&& Values.Contains(4)
		&& Other.Num() == 2;
}
/** @end */
