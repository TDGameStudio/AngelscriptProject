/**
 * @version v1
 * @summary A const&in TSet<FName> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFName
 */
/**
 * @begin ReadEmptyClearsNumFName
 * @summary A const&in TSet<FName> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFName(const TSet<FName>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
