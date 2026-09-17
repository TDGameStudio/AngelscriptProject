/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumUObject
 */
/**
 * @begin ReadEmptyClearsNumUObject
 * @summary A const&in TArray<UObject> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumUObject(const TArray<UObject>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
