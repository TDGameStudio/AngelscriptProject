/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Append of another set.
 * @topic Containers
 *
 * MutateAppendOtherSetUObject
 */
/**
 * @begin MutateAppendOtherSetUObject
 * @summary An &inout TSet<UObject> receives Append of another set.
 * @topic Containers
 */
UCLASS()
class UTSetMutateAppendOtherSetUObjectHost : UObject
{
}

void MutateAppendOtherSetUObject(TSet<UObject>&inout Values)
{
	TSet<UObject> Other;
	Other.Add(NewObject(GetTransientPackage(), UTSetMutateAppendOtherSetUObjectHost::StaticClass(), n"MutateAppendOtherSet_0", true));
	Other.Add(NewObject(GetTransientPackage(), UTSetMutateAppendOtherSetUObjectHost::StaticClass(), n"MutateAppendOtherSet_1", true));
	Values.Append(Other);
}
/** @end */
