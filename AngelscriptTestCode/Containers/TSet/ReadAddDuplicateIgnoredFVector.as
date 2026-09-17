/**
 * @version v1
 * @summary A const&in TSet<FVector> reports a single unique member after duplicate Add.
 * @topic Containers
 *
 * ReadAddDuplicateIgnoredFVector
 */
/**
 * @begin ReadAddDuplicateIgnoredFVector
 * @summary A const&in TSet<FVector> reports a single unique member after duplicate Add.
 * @topic Containers
 */
bool ReadAddDuplicateIgnoredFVector(const TSet<FVector>&in Values)
{
	return Values.Num() == 1 && Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
