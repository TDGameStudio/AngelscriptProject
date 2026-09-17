/**
 * @version v1
 * @summary Set then Reset on a TOptional UPROPERTY leaves the instance unset.
 * @topic Containers
 *
 * PropertySetAndReset
 */
/**
 * @begin PropertySetAndReset
 * @summary Set then Reset on a TOptional UPROPERTY leaves the instance unset.
 * @topic Containers
 */
UCLASS()
class UTOptionalPropertySetAndResetHolder : UObject
{
	UPROPERTY()
	TOptional<int32> Value;
}

bool PropertySetAndReset()
{
	UTOptionalPropertySetAndResetHolder Holder = Cast<UTOptionalPropertySetAndResetHolder>(
		NewObject(GetTransientPackage(), UTOptionalPropertySetAndResetHolder::StaticClass(), n"TOptionalProperty_SetReset", true));
	if (Holder == nullptr)
	{
		return false;
	}

	Holder.Value.Set(42);
	if (!Holder.Value.IsSet() || Holder.Value.GetValue() != 42)
	{
		return false;
	}

	Holder.Value.Reset();
	return !Holder.Value.IsSet() && Holder.Value.Get(7) == 7;
}
/** @end */
