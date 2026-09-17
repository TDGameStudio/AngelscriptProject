/**
 * @version v1
 * @summary AddUnique is false for a duplicate FVector and true for a new value.
 * @topic Containers
 *
 * AddUniqueRejectsDuplicateFVector
 */
/**
 * @begin AddUniqueRejectsDuplicateFVector
 * @summary AddUnique is false for a duplicate FVector and true for a new value.
 * @topic Containers
 */
bool AddUniqueRejectsDuplicateFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	bool bDuplicate = Values.AddUnique(FVector(1.0f, 0.0f, 0.0f));
	bool bUnique = Values.AddUnique(FVector(0.0f, 1.0f, 0.0f));
	return !bDuplicate && bUnique && Values.Num() == 2 && Values.Contains(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
