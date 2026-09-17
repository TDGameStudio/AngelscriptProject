/**
 * @version v1
 * @summary An &inout TArray<UObject> receives Append of NewObject handles.
 * @topic Containers
 *
 * MutateAppendOtherArrayUObject
 */
/**
 * @begin MutateAppendOtherArrayUObject
 * @summary An &inout TArray<UObject> receives Append of NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateAppendOtherArrayUObjectHost : UObject
{
}

void MutateAppendOtherArrayUObject(TArray<UObject>&inout Values)
{
	TArray<UObject> Other;
	Other.Add(NewObject(GetTransientPackage(), UTArrayMutateAppendOtherArrayUObjectHost::StaticClass(), n"MutateAppend_1", true));
	Other.Add(NewObject(GetTransientPackage(), UTArrayMutateAppendOtherArrayUObjectHost::StaticClass(), n"MutateAppend_2", true));
	Values.Append(Other);
}
/** @end */
