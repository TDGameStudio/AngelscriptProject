/**
 * @version v1
 * @summary A const&in TSet<FString> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFString
 */
/**
 * @begin ReadEmptyClearsNumFString
 * @summary A const&in TSet<FString> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFString(const TSet<FString>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
