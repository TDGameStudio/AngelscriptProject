/**
 * @version v1
 * @summary A const&in TSet<int32> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNum
 */
/**
 * @begin ReadEmptyClearsNum
 * @summary A const&in TSet<int32> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNum(const TSet<int32>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
