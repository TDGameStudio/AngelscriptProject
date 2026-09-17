/**
 * @version v1
 * @summary A const&in TSet<bool> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumBool
 */
/**
 * @begin ReadEmptyClearsNumBool
 * @summary A const&in TSet<bool> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumBool(const TSet<bool>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
