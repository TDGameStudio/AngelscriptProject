/**
 * @version v1
 * @summary A const&in TArray<FString> reports FindIndex first match or -1.
 * @topic Containers
 *
 * ReadFindIndexReturnsFirstOrMinusOneFString
 */
/**
 * @begin ReadFindIndexReturnsFirstOrMinusOneFString
 * @summary A const&in TArray<FString> reports FindIndex first match or -1.
 * @topic Containers
 */
bool ReadFindIndexReturnsFirstOrMinusOneFString(const TArray<FString>&in Values)
{
	return Values.FindIndex("alpha") == 0 && Values.FindIndex("beta") == 1 && Values.FindIndex("omega") == -1;
}
/** @end */
