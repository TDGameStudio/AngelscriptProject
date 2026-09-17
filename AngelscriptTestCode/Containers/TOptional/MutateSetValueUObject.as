/**
 * @version v1
 * @summary An &inout TOptional<UObject> is overwritten by Set of a new handle.
 * @topic Containers
 *
 * MutateSetValueUObject
 */
/**
 * @begin MutateSetValueUObject
 * @summary An &inout TOptional<UObject> is overwritten by Set of a new handle.
 * @topic Containers
 */
UCLASS()
class UTOptionalMutateSetValueUObjectHost : UObject
{
}

void MutateSetValueUObject(TOptional<UObject>&inout Value)
{
	Value.Set(NewObject(GetTransientPackage(), UTOptionalMutateSetValueUObjectHost::StaticClass(), n"MutateSetValue_Replace", true));
}
/** @end */
