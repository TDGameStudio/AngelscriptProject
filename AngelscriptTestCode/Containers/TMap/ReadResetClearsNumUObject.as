/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumUObject
 */
/**
 * @begin ReadResetClearsNumUObject
 * @summary A const&in TMap<int, UObject> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumUObject(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
