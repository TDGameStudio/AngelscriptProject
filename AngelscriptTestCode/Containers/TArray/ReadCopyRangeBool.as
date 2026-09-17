/**
 * @version v1
 * @summary A const&in TArray<bool> reports a copied run.
 * @topic Containers
 *
 * ReadCopyRangeBool
 */
/**
 * @begin ReadCopyRangeBool
 * @summary A const&in TArray<bool> reports a copied run.
 * @topic Containers
 */
bool ReadCopyRangeBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
}
/** @end */
