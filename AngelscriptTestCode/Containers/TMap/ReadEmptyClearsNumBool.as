/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumBool
 */
/**
 * @begin ReadEmptyClearsNumBool
 * @summary A const&in TMap<int, bool> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumBool(const TMap<int, bool>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
