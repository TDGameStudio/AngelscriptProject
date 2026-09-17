/**
 * @version v1
 * @summary A const&in TArray<int32> reports the array after Remove deleted every match.
 * @topic Containers
 *
 * ReadRemoveAllMatches
 */
/**
 * @begin ReadRemoveAllMatches
 * @summary A const&in TArray<int32> reports the array after Remove deleted every match.
 * @topic Containers
 */
bool ReadRemoveAllMatches(const TArray<int32>&in Values)
{
	return Values.Num() == 4
		&& Values[0] == 1 && Values[1] == 3 && Values[2] == 4 && Values[3] == 5;
}
/** @end */
