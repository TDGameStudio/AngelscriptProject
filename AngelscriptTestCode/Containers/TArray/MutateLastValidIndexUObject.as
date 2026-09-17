/**
 * @version v1
 * @summary An &inout TArray<UObject> overwrites Last() in place.
 * @topic Containers
 *
 * MutateLastValidIndexUObject
 */
/**
 * @begin MutateLastValidIndexUObject
 * @summary An &inout TArray<UObject> overwrites Last() in place.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateLastValidIndexUObjectHost : UObject
{
}

void MutateLastValidIndexUObject(TArray<UObject>&inout Values)
{
	Values.Last() = NewObject(GetTransientPackage(), UTArrayMutateLastValidIndexUObjectHost::StaticClass(), n"MutateLastValidIndex_Wrote", true);
}
/** @end */
