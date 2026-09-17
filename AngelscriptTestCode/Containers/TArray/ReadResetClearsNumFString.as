/**
 * @version v1
 * @summary A const&in TArray<FString> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFString
 */
/**
 * @begin ReadResetClearsNumFString
 * @summary A const&in TArray<FString> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFString(const TArray<FString>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
