/**
 * @version v1
 * @summary A const&in TArray<int32> reports [] insertion order.
 * @topic Containers
 *
 * ReadIndexAccessReadsAndWrites
 */
/**
 * @begin ReadIndexAccessReadsAndWrites
 * @summary A const&in TArray<int32> reports [] insertion order.
 * @topic Containers
 */
bool ReadIndexAccessReadsAndWrites(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
}
/** @end */
