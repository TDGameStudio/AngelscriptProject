/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 *
 * FillByMoveAssignFromUObject
 */
/**
 * @begin FillByMoveAssignFromUObject
 * @summary An &out TArray<UObject> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByMoveAssignFromUObjectHost : UObject
{
}

void FillByMoveAssignFromUObject(TArray<UObject>&out Result)
{
	TArray<UObject> Source;
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByMoveAssignFromUObjectHost::StaticClass(), n"FillByMoveAssignFrom_0", true));
	Source.Add(NewObject(GetTransientPackage(), UTArrayFillByMoveAssignFromUObjectHost::StaticClass(), n"FillByMoveAssignFrom_1", true));
	Result.MoveAssignFrom(Source);
}
/** @end */
