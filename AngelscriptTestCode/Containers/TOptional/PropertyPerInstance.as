/**
 * @version v1
 * @summary Two instances hold independent TOptional UPROPERTY state.
 * @topic Containers
 *
 * PropertyPerInstance
 */
/**
 * @begin PropertyPerInstance
 * @summary Two instances hold independent TOptional UPROPERTY state.
 * @topic Containers
 */
UCLASS()
class UTOptionalPropertyPerInstanceHolder : UObject
{
	UPROPERTY()
	TOptional<int32> Value;
}

bool PropertyPerInstance()
{
	UTOptionalPropertyPerInstanceHolder First = Cast<UTOptionalPropertyPerInstanceHolder>(
		NewObject(GetTransientPackage(), UTOptionalPropertyPerInstanceHolder::StaticClass(), n"TOptionalProperty_First", true));
	UTOptionalPropertyPerInstanceHolder Second = Cast<UTOptionalPropertyPerInstanceHolder>(
		NewObject(GetTransientPackage(), UTOptionalPropertyPerInstanceHolder::StaticClass(), n"TOptionalProperty_Second", true));
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	First.Value.Set(42);
	return First.Value.IsSet()
		&& First.Value.GetValue() == 42
		&& !Second.Value.IsSet();
}
/** @end */
