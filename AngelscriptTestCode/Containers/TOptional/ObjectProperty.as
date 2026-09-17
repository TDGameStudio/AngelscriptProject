/**
 * @version v1
 * @summary A TOptional UPROPERTY starts unset on a fresh instance.
 * @topic Containers
 *
 * ObjectProperty
 */
/**
 * @begin ObjectProperty
 * @summary A TOptional UPROPERTY starts unset on a fresh instance.
 * @topic Containers
 */
UCLASS()
class UTOptionalPropertyHolder : UObject
{
	UPROPERTY()
	TOptional<int32> Value;
}

bool ObjectProperty()
{
	UTOptionalPropertyHolder Holder = Cast<UTOptionalPropertyHolder>(
		NewObject(GetTransientPackage(), UTOptionalPropertyHolder::StaticClass(), n"TOptionalProperty_Host", true));
	if (Holder == nullptr)
	{
		return false;
	}

	return !Holder.Value.IsSet();
}
/** @end */
