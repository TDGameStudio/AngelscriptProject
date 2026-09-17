/**
 * @version v1
 * @summary AddUnique is false for a duplicate float and true for a new value.
 * @topic Containers
 *
 * AddUniqueRejectsDuplicateFloat
 */
/**
 * @begin AddUniqueRejectsDuplicateFloat
 * @summary AddUnique is false for a duplicate float and true for a new value.
 * @topic Containers
 */
bool AddUniqueRejectsDuplicateFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	bool bDuplicate = Values.AddUnique(1.0f);
	bool bUnique = Values.AddUnique(4.0f);
	return !bDuplicate && bUnique && Values.Num() == 2 && Values.Contains(4.0f);
}
/** @end */
