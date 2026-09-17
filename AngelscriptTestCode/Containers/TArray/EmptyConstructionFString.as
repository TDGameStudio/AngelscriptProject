/**
 * @version v1
 * @summary Default TArray<FString> is empty.
 * @topic Containers
 *
 * EmptyConstructionFString
 */
/**
 * @begin EmptyConstructionFString
 * @summary Default TArray<FString> is empty.
 * @topic Containers
 */
bool EmptyConstructionFString()
{
	TArray<FString> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
