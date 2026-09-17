/**
 * @version v1
 * @summary A const&in TArray<float> reports the array after Remove deleted every match.
 * @topic Containers
 *
 * ReadRemoveAllMatchesFloat
 */
/**
 * @begin ReadRemoveAllMatchesFloat
 * @summary A const&in TArray<float> reports the array after Remove deleted every match.
 * @topic Containers
 */
bool ReadRemoveAllMatchesFloat(const TArray<float>&in Values)
{
	return Values.Num() == 4
		&& Values[0] == 1.0f && Values[1] == 3.0f && Values[2] == 4.0f && Values[3] == 5.0f;
}
/** @end */
