/**
 * @version v1
 * @summary Append unions another UObject set and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherSetUObject
 */
/**
 * @begin AppendOtherSetUObject
 * @summary Append unions another UObject set and leaves the source unchanged.
 * @topic Containers
 */
UCLASS()
class UTSetAppendOtherSetUObjectHost : UObject
{
}

bool AppendOtherSetUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTSetAppendOtherSetUObjectHost::StaticClass(), n"AppendOtherSet_First", true);
	UObject Third = NewObject(GetTransientPackage(), UTSetAppendOtherSetUObjectHost::StaticClass(), n"AppendOtherSet_Third", true);
	UObject Fourth = NewObject(GetTransientPackage(), UTSetAppendOtherSetUObjectHost::StaticClass(), n"AppendOtherSet_Fourth", true);
	TSet<UObject> Values;
	Values.Add(First);
	TSet<UObject> Other;
	Other.Add(Third);
	Other.Add(Fourth);
	Values.Append(Other);
	return Values.Num() == 3
		&& Values.Contains(First)
		&& Values.Contains(Third)
		&& Values.Contains(Fourth)
		&& Other.Num() == 2;
}
/** @end */
