/**
 * @version v1
 * @summary An &inout TOptional<UObject> is rewritten through GetValue.
 * @topic Containers
 *
 * MutateGetValueReturnsStoredIntUObject
 */
/**
 * @begin MutateGetValueReturnsStoredIntUObject
 * @summary An &inout TOptional<UObject> is rewritten through GetValue.
 * @topic Containers
 */
UCLASS()
class UTOptionalMutateGetValueReturnsStoredIntUObjectHost : UObject
{
}

void MutateGetValueReturnsStoredIntUObject(TOptional<UObject>&inout Value)
{
	Value.GetValue() = NewObject(GetTransientPackage(), UTOptionalMutateGetValueReturnsStoredIntUObjectHost::StaticClass(), n"MutateGetValueReturnsStoredInt_Replace", true);
}
/** @end */
