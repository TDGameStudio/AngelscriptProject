/**
 * @version v1
 * @summary A const&in TMap<int, int> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNum
 */
/**
 * @begin ReadEmptyClearsNum
 * @summary A const&in TMap<int, int> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNum(const TMap<int, int>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
