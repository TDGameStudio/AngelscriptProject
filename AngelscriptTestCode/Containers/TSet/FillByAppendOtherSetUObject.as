/**
 * @version v1
 * @summary An &out TSet<UObject> is filled by Append of another set.
 * @topic Containers
 *
 * FillByAppendOtherSetUObject
 */
/**
 * @begin FillByAppendOtherSetUObject
 * @summary An &out TSet<UObject> is filled by Append of another set.
 * @topic Containers
 */
UCLASS()
class UTSetFillByAppendOtherSetUObjectHost : UObject
{
}

void FillByAppendOtherSetUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByAppendOtherSetUObjectHost::StaticClass(), n"FillByAppendOtherSet_0", true));
	TSet<UObject> Other;
	Other.Add(NewObject(GetTransientPackage(), UTSetFillByAppendOtherSetUObjectHost::StaticClass(), n"FillByAppendOtherSet_1", true));
	Other.Add(NewObject(GetTransientPackage(), UTSetFillByAppendOtherSetUObjectHost::StaticClass(), n"FillByAppendOtherSet_2", true));
	Result.Append(Other);
}
/** @end */
