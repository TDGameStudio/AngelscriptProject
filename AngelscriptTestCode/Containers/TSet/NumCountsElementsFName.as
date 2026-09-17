/**
 * @version v1
 * @summary Num counts unique FName members and ignores a duplicate Add.
 * @topic Containers
 *
 * NumCountsElementsFName
 */
/**
 * @begin NumCountsElementsFName
 * @summary Num counts unique FName members and ignores a duplicate Add.
 * @topic Containers
 */
bool NumCountsElementsFName()
{
	TSet<FName> Empty;
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Add(n"Green");
	Values.Add(n"Red");
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
