/**
 * @version v1
 * @summary An &inout TSet<UObject> is replaced by assigning a new set.
 * @topic Containers
 *
 * MutateCopyAssignUObject
 */
/**
 * @begin MutateCopyAssignUObject
 * @summary An &inout TSet<UObject> is replaced by assigning a new set.
 * @topic Containers
 */
UCLASS()
class UTSetMutateCopyAssignUObjectHost : UObject
{
}

void MutateCopyAssignUObject(TSet<UObject>&inout Values)
{
	TSet<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTSetMutateCopyAssignUObjectHost::StaticClass(), n"MutateCopyAssign_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTSetMutateCopyAssignUObjectHost::StaticClass(), n"MutateCopyAssign_1", true));
	Values = Source;
}
/** @end */
