/**
 * @version v1
 * @summary An &inout TArray<UObject> is replaced by assigning a new sequence.
 * @topic Containers
 *
 * MutateCopyAssignUObject
 */
/**
 * @begin MutateCopyAssignUObject
 * @summary An &inout TArray<UObject> is replaced by assigning a new sequence.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateCopyAssignUObjectHost : UObject
{
}

void MutateCopyAssignUObject(TArray<UObject>&inout Values)
{
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayMutateCopyAssignUObjectHost::StaticClass(), n"MutateCopyAssign_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayMutateCopyAssignUObjectHost::StaticClass(), n"MutateCopyAssign_1", true));
	Values = Source;
}
/** @end */
