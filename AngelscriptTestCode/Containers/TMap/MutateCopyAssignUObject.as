/**
 * @version v1
 * @summary An &inout TMap<int, UObject> is replaced by assigning a new map.
 * @topic Containers
 *
 * MutateCopyAssignUObject
 */
/**
 * @begin MutateCopyAssignUObject
 * @summary An &inout TMap<int, UObject> is replaced by assigning a new map.
 * @topic Containers
 */
UCLASS()
class UTMapMutateCopyAssignUObjectHost : UObject
{
}

void MutateCopyAssignUObject(TMap<int, UObject>&inout Values)
{
	TMap<int, UObject> Source;
	Source.Add(10, NewObject(GetTransientPackage(), UTMapMutateCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Mutate_0", true));
	Source.Add(20, NewObject(GetTransientPackage(), UTMapMutateCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Mutate_1", true));
	Source.Add(30, NewObject(GetTransientPackage(), UTMapMutateCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Mutate_2", true));
	Values = Source;
}
/** @end */
