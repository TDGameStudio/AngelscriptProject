/**
 * @version v1
 * @summary An &out TSet<UObject> is filled by Add of three NewObject handles.
 * @topic Containers
 *
 * FillByAddElementIsContainedUObject
 */
/**
 * @begin FillByAddElementIsContainedUObject
 * @summary An &out TSet<UObject> is filled by Add of three NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTSetFillByAddElementIsContainedUObjectHost : UObject
{
}

void FillByAddElementIsContainedUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByAddElementIsContainedUObjectHost::StaticClass(), n"FillByAddElementIsContained_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByAddElementIsContainedUObjectHost::StaticClass(), n"FillByAddElementIsContained_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByAddElementIsContainedUObjectHost::StaticClass(), n"FillByAddElementIsContained_2", true));
}
/** @end */
