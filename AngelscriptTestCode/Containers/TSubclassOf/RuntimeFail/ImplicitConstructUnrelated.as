/**
 * @version v1
 * @summary Implicit construct from an unrelated class throws Class set to TSubclassOf<> was not a child of templated class.
 * @topic Containers
 *
 * ImplicitConstructUnrelated
 */
/**
 * @begin ImplicitConstructUnrelated
 * @summary Implicit construct from an unrelated class throws Class set to TSubclassOf<> was not a child of templated class.
 * @topic Containers
 */
UCLASS()
class UImplicitUnrelatedBase : UObject
{
}

UCLASS()
class UImplicitUnrelatedOther : UObject
{
}

void ImplicitConstructUnrelated()
{
	TSubclassOf<UImplicitUnrelatedBase> Class = UImplicitUnrelatedOther::StaticClass();
}
/** @end */
