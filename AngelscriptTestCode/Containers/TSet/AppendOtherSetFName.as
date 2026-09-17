/**
 * @version v1
 * @summary Append unions another FName set and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherSetFName
 */
/**
 * @begin AppendOtherSetFName
 * @summary Append unions another FName set and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherSetFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	TSet<FName> Other;
	Other.Add(n"Blue");
	Other.Add(n"Yellow");
	Values.Append(Other);
	return Values.Num() == 3
		&& Values.Contains(n"Red")
		&& Values.Contains(n"Blue")
		&& Values.Contains(n"Yellow")
		&& Other.Num() == 2;
}
/** @end */
