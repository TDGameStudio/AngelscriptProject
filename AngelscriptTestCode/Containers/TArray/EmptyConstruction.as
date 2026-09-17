/**
 * @version v1
 * @summary Default TArray<int32> and TArray<FName> are empty.
 * @topic Containers
 *
 * EmptyConstruction
 */
/**
 * @begin EmptyConstruction
 * @summary Default TArray<int32> and TArray<FName> are empty.
 * @topic Containers
 */
bool EmptyConstruction()
{
	TArray<int32> Numbers;
	TArray<FName> Names;
	return Numbers.IsEmpty() && Numbers.Num() == 0
		&& Names.IsEmpty() && Names.Num() == 0;
}
/** @end */
