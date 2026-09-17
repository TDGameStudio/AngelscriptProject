/**
 * @version v1
 * @summary A duplicate FVector Add is ignored and is not appended.
 * @topic Containers
 *
 * AddDuplicateIgnoredFVector
 */
/**
 * @begin AddDuplicateIgnoredFVector
 * @summary A duplicate FVector Add is ignored and is not appended.
 * @topic Containers
 */
bool AddDuplicateIgnoredFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	if (Values.Num() != 1 || !Values.Contains(FVector(1.0f, 0.0f, 0.0f)))
	{
		return false;
	}

	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	return Values.Num() == 1 && Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
