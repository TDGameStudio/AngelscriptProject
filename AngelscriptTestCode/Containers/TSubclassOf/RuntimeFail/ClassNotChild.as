/**
 * @version v1
 * @summary Set of an unrelated class throws Class set to TSubclassOf<> was not a child of templated class.
 * @topic Containers
 *
 * ClassNotChild
 */
/**
 * @begin ClassNotChild
 * @summary Set of an unrelated class throws Class set to TSubclassOf<> was not a child of templated class.
 * @topic Containers
 */
UCLASS()
class UClassNotChildBase : UObject
{
}

UCLASS()
class UClassNotChildUnrelated : UObject
{
}

void ClassNotChild()
{
	TSubclassOf<UClassNotChildBase> Class;
	Class.Set(UClassNotChildUnrelated::StaticClass());
}
/** @end */
