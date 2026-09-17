/**
 * @version v1
 * @summary An &inout TOptional<UObject> is overwritten so Get returns the new stored handle.
 * @topic Containers
 *
 * MutateGetReturnsStoredValueUObject
 */
/**
 * @begin MutateGetReturnsStoredValueUObject
 * @summary An &inout TOptional<UObject> is overwritten so Get returns the new stored handle.
 * @topic Containers
 */
UCLASS()
class UTOptionalMutateGetReturnsStoredValueUObjectHost : UObject
{
}

void MutateGetReturnsStoredValueUObject(TOptional<UObject>&inout Value)
{
	Value.Set(NewObject(GetTransientPackage(), UTOptionalMutateGetReturnsStoredValueUObjectHost::StaticClass(), n"MutateGetReturnsStoredValue_Replace", true));
}
/** @end */
