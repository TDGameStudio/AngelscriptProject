/**
 * @version v1
 * @summary A const&in TSet<FString> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFString
 */
/**
 * @begin ReadResetClearsNumFString
 * @summary A const&in TSet<FString> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFString(const TSet<FString>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
