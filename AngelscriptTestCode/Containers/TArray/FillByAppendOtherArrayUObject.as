/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by Append of NewObject handles.
 * @topic Containers
 *
 * FillByAppendOtherArrayUObject
 */
/**
 * @begin FillByAppendOtherArrayUObject
 * @summary An &out TArray<UObject> is filled by Append of NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByAppendOtherArrayUObjectHost : UObject
{
}

void FillByAppendOtherArrayUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByAppendOtherArrayUObjectHost::StaticClass(), n"FillByAppend_0", true));
	TArray<UObject> Other;
	Other.Add(NewObject(GetTransientPackage(), UTArrayFillByAppendOtherArrayUObjectHost::StaticClass(), n"FillByAppend_1", true));
	Other.Add(NewObject(GetTransientPackage(), UTArrayFillByAppendOtherArrayUObjectHost::StaticClass(), n"FillByAppend_2", true));
	Result.Append(Other);
}
/** @end */
