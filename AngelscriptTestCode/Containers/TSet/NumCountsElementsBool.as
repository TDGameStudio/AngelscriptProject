/**
 * @version v1
 * @summary Num counts unique bool members and ignores a duplicate Add.
 * @topic Containers
 *
 * NumCountsElementsBool
 */
/**
 * @begin NumCountsElementsBool
 * @summary Num counts unique bool members and ignores a duplicate Add.
 * @topic Containers
 */
bool NumCountsElementsBool()
{
	TSet<bool> Empty;
	TSet<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
