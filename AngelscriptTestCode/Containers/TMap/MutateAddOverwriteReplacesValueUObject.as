/**
 * @version v1
 * @summary An &inout TMap<int, UObject> overwrites an existing key by Add.
 * @topic Containers
 *
 * MutateAddOverwriteReplacesValueUObject
 */
/**
 * @begin MutateAddOverwriteReplacesValueUObject
 * @summary An &inout TMap<int, UObject> overwrites an existing key by Add.
 * @topic Containers
 */
UCLASS()
class UTMapMutateAddOverwriteReplacesValueUObjectHost : UObject
{
}

void MutateAddOverwriteReplacesValueUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(10, NewObject(GetTransientPackage(), UTMapMutateAddOverwriteReplacesValueUObjectHost::StaticClass(), n"AddOverwrite_Mutate", true));
}
/** @end */
