/**
 * @version v1
 * @summary An &out TSet<UObject> is filled then Remove drops one member.
 * @topic Containers
 *
 * FillByRemoveElementDropsMemberUObject
 */
/**
 * @begin FillByRemoveElementDropsMemberUObject
 * @summary An &out TSet<UObject> is filled then Remove drops one member.
 * @topic Containers
 */
UCLASS()
class UTSetFillByRemoveElementDropsMemberUObjectHost : UObject
{
}

void FillByRemoveElementDropsMemberUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByRemoveElementDropsMemberUObjectHost::StaticClass(), n"FillByRemoveElementDropsMember_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByRemoveElementDropsMemberUObjectHost::StaticClass(), n"FillByRemoveElementDropsMember_1", true));
	UObject Drop = nullptr;
	for (UObject Item : Result)
	{
		Drop = Item;
		break;
	}
	Result.Remove(Drop);
}
/** @end */
