/**
 * @version v1
 * @summary Num counts unique UObject members and ignores a duplicate Add.
 * @topic Containers
 *
 * NumCountsElementsUObject
 */
/**
 * @begin NumCountsElementsUObject
 * @summary Num counts unique UObject members and ignores a duplicate Add.
 * @topic Containers
 */
UCLASS()
class UTSetNumCountsElementsUObjectHost : UObject
{
}

bool NumCountsElementsUObject()
{
	TSet<UObject> Empty;
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetNumCountsElementsUObjectHost::StaticClass(), n"NumCountsElements_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetNumCountsElementsUObjectHost::StaticClass(), n"NumCountsElements_Second", true);
	Values.Add(First);
	Values.Add(Second);
	Values.Add(First);
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
