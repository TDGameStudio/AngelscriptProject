/**
 * @version v1
 * @summary An &inout TArray<UObject> replaces every handle in place by range-for ref.
 * @topic Containers
 *
 * MutateForEachElementUObject
 */
/**
 * @begin MutateForEachElementUObject
 * @summary An &inout TArray<UObject> replaces every handle in place by range-for ref.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateForEachElementUObjectHost : UObject
{
}

void MutateForEachElementUObject(TArray<UObject>&inout Values)
{
	UObject Replacement = NewObject(GetTransientPackage(), UTArrayMutateForEachElementUObjectHost::StaticClass(), n"MutateForEachElement_R", true);
	for (UObject& Value : Values)
	{
		Value = Replacement;
	}
}
/** @end */
