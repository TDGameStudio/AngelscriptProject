/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumUObject
 */
/**
 * @begin ReadEmptyClearsNumUObject
 * @summary A const&in TMap<int, UObject> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumUObject(const TMap<int, UObject>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
