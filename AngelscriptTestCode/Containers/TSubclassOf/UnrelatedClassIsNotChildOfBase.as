/**
 * @version v1
 * @summary An unrelated class held in TSubclassOf is not a child of another base.
 * @topic Containers
 *
 * UnrelatedClassIsNotChildOfBase
 */
/**
 * @begin UnrelatedClassIsNotChildOfBase
 * @summary An unrelated class held in TSubclassOf is not a child of another base.
 * @topic Containers
 */
UCLASS()
class UUnrelatedNotChildBase : UObject
{
}

UCLASS()
class UUnrelatedNotChildOther : UObject
{
}

bool UnrelatedClassIsNotChildOfBase()
{
	TSubclassOf<UObject> Class;
	Class = UUnrelatedNotChildOther::StaticClass();
	return Class.IsValid()
		&& !Class.IsChildOf(UUnrelatedNotChildBase::StaticClass());
}
/** @end */
