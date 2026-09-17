/**
 * @version v1
 * @summary Pointers to different targets are unequal.
 * @topic Containers
 *
 * PointersToDifferentTargetsAreUnequal
 */
/**
 * @begin PointersToDifferentTargetsAreUnequal
 * @summary Pointers to different targets are unequal.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrDifferentTargets : UObject
{
}

bool PointersToDifferentTargetsAreUnequal()
{
	UObject First = NewObject(GetTransientPackage(), UTObjectPtrDifferentTargets::StaticClass(), n"TObjPtrValid_Diff0", true);
	UObject Second = NewObject(GetTransientPackage(), UTObjectPtrDifferentTargets::StaticClass(), n"TObjPtrValid_Diff1", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	TObjectPtr<UObject> Left;
	TObjectPtr<UObject> Right;
	Left = First;
	Right = Second;
	return Left != Right;
}
/** @end */
