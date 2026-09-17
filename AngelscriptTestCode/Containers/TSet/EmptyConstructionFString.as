/**
 * @version v1
 * @summary Default TSet<FString> is empty.
 * @topic Containers
 *
 * EmptyConstructionFString
 */
/**
 * @begin EmptyConstructionFString
 * @summary Default TSet<FString> is empty.
 * @topic Containers
 */
bool EmptyConstructionFString()
{
	TSet<FString> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
