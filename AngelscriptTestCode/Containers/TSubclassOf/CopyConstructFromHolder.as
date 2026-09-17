/**
 * @version v1
 * @summary Copy-constructing TSubclassOf from another holder copies the class.
 * @topic Containers
 *
 * CopyConstructFromHolder
 */
/**
 * @begin CopyConstructFromHolder
 * @summary Copy-constructing TSubclassOf from another holder copies the class.
 * @topic Containers
 */
UCLASS()
class UCopyConstructFromHolderObject : UObject
{
}

bool CopyConstructFromHolder()
{
	TSubclassOf<UObject> Source;
	UClass Expected = UCopyConstructFromHolderObject::StaticClass();
	Source = Expected;
	TSubclassOf<UObject> Copy = Source;
	return Copy.IsValid() && Copy.Get() == Expected && Source.Get() == Expected;
}
/** @end */
