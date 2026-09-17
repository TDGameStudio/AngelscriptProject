/**
 * @version v1
 * @summary A const&in TArray<bool> reports Append order.
 * @topic Containers
 *
 * ReadAppendOtherArrayBool
 */
/**
 * @begin ReadAppendOtherArrayBool
 * @summary A const&in TArray<bool> reports Append order.
 * @topic Containers
 */
bool ReadAppendOtherArrayBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
}
/** @end */
