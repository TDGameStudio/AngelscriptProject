/**
 * @version v1
 * @summary Assigning one TSubclassOf onto another copies the class and stays independent.
 * @topic Containers
 *
 * AssignHolderCopiesClassAndStaysIndependent
 */
/**
 * @begin AssignHolderCopiesClassAndStaysIndependent
 * @summary Assigning one TSubclassOf onto another copies the class and stays independent.
 * @topic Containers
 */
UCLASS()
class UHolderCopyFirstObject : UObject
{
}

UCLASS()
class UHolderCopySecondObject : UObject
{
}

bool AssignHolderCopiesClassAndStaysIndependent()
{
	TSubclassOf<UObject> Source;
	UClass First = UHolderCopyFirstObject::StaticClass();
	UClass Second = UHolderCopySecondObject::StaticClass();
	if (First == Second)
	{
		return false;
	}

	Source = First;
	TSubclassOf<UObject> Dest;
	Dest = Source;
	if (!Dest.IsValid() || Dest.Get() != First || Dest != Source)
	{
		return false;
	}

	Source = Second;
	return Dest.Get() == First && Source.Get() == Second && Dest != Source;
}
/** @end */
