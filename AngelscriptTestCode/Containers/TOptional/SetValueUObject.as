/**
 * @version v1
 * @summary Set stores a UObject handle and marks the optional set.
 * @topic Containers
 *
 * SetValueUObject
 */
/**
 * @begin SetValueUObject
 * @summary Set stores a UObject handle and marks the optional set.
 * @topic Containers
 */
UCLASS()
class UTOptionalSetValueUObjectHost : UObject
{
}

bool SetValueUObject()
{
	TOptional<UObject> Optional;
	UObject First = NewObject(GetTransientPackage(), UTOptionalSetValueUObjectHost::StaticClass(), n"SetValue_First", true);
	if (First == nullptr)
	{
		return false;
	}

	Optional.Set(First);
	return Optional.IsSet() && Optional.GetValue() == First;
}
/** @end */
