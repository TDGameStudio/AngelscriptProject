/**
 * @version v1
 * @summary An &inout TOptional<UObject> is overwritten by copy assignment.
 * @topic Containers
 *
 * MutateCopyAssignUObject
 */
/**
 * @begin MutateCopyAssignUObject
 * @summary An &inout TOptional<UObject> is overwritten by copy assignment.
 * @topic Containers
 */
UCLASS()
class UTOptionalMutateCopyAssignUObjectHost : UObject
{
}

void MutateCopyAssignUObject(TOptional<UObject>&inout Value)
{
	TOptional<UObject> Other;
	Other.Set(NewObject(GetTransientPackage(), UTOptionalMutateCopyAssignUObjectHost::StaticClass(), n"MutateCopyAssign_Replace", true));
	Value = Other;
}
/** @end */
