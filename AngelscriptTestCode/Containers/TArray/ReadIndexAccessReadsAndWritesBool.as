/**
 * @version v1
 * @summary A const&in TArray<bool> reports [] insertion order.
 * @topic Containers
 *
 * ReadIndexAccessReadsAndWritesBool
 */
/**
 * @begin ReadIndexAccessReadsAndWritesBool
 * @summary A const&in TArray<bool> reports [] insertion order.
 * @topic Containers
 */
bool ReadIndexAccessReadsAndWritesBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
}
/** @end */
