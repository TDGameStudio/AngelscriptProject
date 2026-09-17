/**
 * @version v1
 * @summary An &inout TArray<UObject> is replaced by MoveAssignFrom.
 * @topic Containers
 *
 * MutateMoveAssignFromUObject
 */
/**
 * @begin MutateMoveAssignFromUObject
 * @summary An &inout TArray<UObject> is replaced by MoveAssignFrom.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateMoveAssignFromUObjectHost : UObject
{
}

void MutateMoveAssignFromUObject(TArray<UObject>&inout Values)
{
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayMutateMoveAssignFromUObjectHost::StaticClass(), n"MutateMoveAssignFrom_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayMutateMoveAssignFromUObjectHost::StaticClass(), n"MutateMoveAssignFrom_1", true));
	Values.MoveAssignFrom(Source);
}
/** @end */
