/**
 * @version v1
 * @summary A const&in TArray<int32> reports Append order.
 * @topic Containers
 *
 * ReadAppendOtherArray
 */
/**
 * @begin ReadAppendOtherArray
 * @summary A const&in TArray<int32> reports Append order.
 * @topic Containers
 */
bool ReadAppendOtherArray(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
}
/** @end */
