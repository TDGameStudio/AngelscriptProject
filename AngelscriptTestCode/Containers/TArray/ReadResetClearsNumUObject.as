/**
 * @version v1
 * @summary A const&in TArray<UObject> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumUObject
 */
/**
 * @begin ReadResetClearsNumUObject
 * @summary A const&in TArray<UObject> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
