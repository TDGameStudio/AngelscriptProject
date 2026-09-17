/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Last() and Last(1) from the end.
 * @topic Containers
 *
 * ReadLastValidIndexUObject
 */
/**
 * @begin ReadLastValidIndexUObject
 * @summary A const&in TArray<UObject> reports Last() and Last(1) from the end.
 * @topic Containers
 */
bool ReadLastValidIndexUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3 && Values.Last() == Values[2] && Values.Last(1) == Values[1] && Values.Last(2) == Values[0];
}
/** @end */
