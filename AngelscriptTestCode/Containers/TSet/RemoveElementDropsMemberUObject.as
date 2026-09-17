/**
 * @version v1
 * @summary Remove of a present UObject member returns true and drops that member.
 * @topic Containers
 *
 * RemoveElementDropsMemberUObject
 */
/**
 * @begin RemoveElementDropsMemberUObject
 * @summary Remove of a present UObject member returns true and drops that member.
 * @topic Containers
 */
UCLASS()
class UTSetRemoveElementDropsMemberUObjectHost : UObject
{
}

bool RemoveElementDropsMemberUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetRemoveElementDropsMemberUObjectHost::StaticClass(), n"RemoveElementDropsMember_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetRemoveElementDropsMemberUObjectHost::StaticClass(), n"RemoveElementDropsMember_Second", true);
	Values.Add(First);
	Values.Add(Second);
	bool bRemoved = Values.Remove(First);
	return bRemoved && Values.Num() == 1 && Values.Contains(Second) && !Values.Contains(First);
}
/** @end */
