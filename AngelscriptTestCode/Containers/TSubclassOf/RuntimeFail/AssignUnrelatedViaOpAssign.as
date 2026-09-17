/**
 * @version v1
 * @summary opAssign of an unrelated class throws Class set to TSubclassOf<> was not a child of templated class.
 * @topic Containers
 *
 * AssignUnrelatedViaOpAssign
 */
/**
 * @begin AssignUnrelatedViaOpAssign
 * @summary opAssign of an unrelated class throws Class set to TSubclassOf<> was not a child of templated class.
 * @topic Containers
 */
UCLASS()
class UAssignUnrelatedBase : UObject
{
}

UCLASS()
class UAssignUnrelatedOther : UObject
{
}

void AssignUnrelatedViaOpAssign()
{
	TSubclassOf<UAssignUnrelatedBase> Class;
	Class = UAssignUnrelatedOther::StaticClass();
}
/** @end */
