/**
 * @version v1
 * @summary An &inout TArray<UObject> receives AddUnique of a new handle and a duplicate identity.
 * @topic Containers
 *
 * MutateAddUniqueRejectsDuplicateUObject
 */
/**
 * @begin MutateAddUniqueRejectsDuplicateUObject
 * @summary An &inout TArray<UObject> receives AddUnique of a new handle and a duplicate identity.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateAddUniqueRejectsDuplicateUObjectHost : UObject
{
}

void MutateAddUniqueRejectsDuplicateUObject(TArray<UObject>&inout Values)
{
	Values.AddUnique(NewObject(GetTransientPackage(), UTArrayMutateAddUniqueRejectsDuplicateUObjectHost::StaticClass(), n"MutateAddUnique_New", true));
	UObject Duplicate = Values[1];
	Values.AddUnique(Duplicate);
}
/** @end */
