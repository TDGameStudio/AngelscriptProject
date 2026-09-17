/**
 * @version v1
 * @summary AddUnique is false for a duplicate and true for a new value.
 * @topic Containers
 *
 * AddUniqueRejectsDuplicate
 */
/**
 * @begin AddUniqueRejectsDuplicate
 * @summary AddUnique is false for a duplicate and true for a new value.
 * @topic Containers
 */
bool AddUniqueRejectsDuplicate()
{
	TArray<int32> Values;
	Values.Add(1);
	bool bDuplicate = Values.AddUnique(1);
	bool bUnique = Values.AddUnique(4);
	return !bDuplicate && bUnique && Values.Num() == 2 && Values.Contains(4);
}
/** @end */
