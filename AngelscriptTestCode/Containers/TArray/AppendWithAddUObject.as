/**
 * @version v1
 * @summary An &inout TArray<UObject> keeps existing handles and Add appends one NewObject.
 * @topic Containers
 *
 * AppendWithAddUObject
 */
/**
 * @begin AppendWithAddUObject
 * @summary An &inout TArray<UObject> keeps existing handles and Add appends one NewObject.
 * @topic Containers
 */
UCLASS()
class UTArrayAppendWithAddUObjectHost : UObject
{
}

void AppendWithAddUObject(TArray<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTArrayAppendWithAddUObjectHost::StaticClass(), n"AppendWithAdd_Tail", true));
}
/** @end */
