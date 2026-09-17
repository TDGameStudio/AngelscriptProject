/**
 * @version v1
 * @summary AddUnique is false for a duplicate UObject handle and true for a new identity.
 * @topic Containers
 *
 * AddUniqueRejectsDuplicateUObject
 */
/**
 * @begin AddUniqueRejectsDuplicateUObject
 * @summary AddUnique is false for a duplicate UObject handle and true for a new identity.
 * @topic Containers
 */
UCLASS()
class UTArrayAddUniqueRejectsDuplicateUObjectHost : UObject
{
}

bool AddUniqueRejectsDuplicateUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayAddUniqueRejectsDuplicateUObjectHost::StaticClass(), n"AddUnique_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayAddUniqueRejectsDuplicateUObjectHost::StaticClass(), n"AddUnique_Second", true);
	Values.Add(First);
	bool bDuplicate = Values.AddUnique(First);
	bool bUnique = Values.AddUnique(Second);
	return !bDuplicate && bUnique && Values.Num() == 2 && Values.Contains(Second);
}
/** @end */
