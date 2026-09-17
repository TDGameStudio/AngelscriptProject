/**
 * @version v1
 * @summary AddUnique is false for a duplicate bool and true for a new value.
 * @topic Containers
 *
 * AddUniqueRejectsDuplicateBool
 */
/**
 * @begin AddUniqueRejectsDuplicateBool
 * @summary AddUnique is false for a duplicate bool and true for a new value.
 * @topic Containers
 */
bool AddUniqueRejectsDuplicateBool()
{
	TArray<bool> Values;
	Values.Add(true);
	bool bDuplicate = Values.AddUnique(true);
	bool bUnique = Values.AddUnique(false);
	return !bDuplicate && bUnique && Values.Num() == 2 && Values.Contains(false);
}
/** @end */
