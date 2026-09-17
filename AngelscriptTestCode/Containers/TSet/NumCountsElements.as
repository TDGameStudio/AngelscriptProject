/**
 * @version v1
 * @summary Num counts unique members and ignores a duplicate Add.
 * @topic Containers
 *
 * NumCountsElements
 */
/**
 * @begin NumCountsElements
 * @summary Num counts unique members and ignores a duplicate Add.
 * @topic Containers
 */
bool NumCountsElements()
{
	TSet<int32> Empty;
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
