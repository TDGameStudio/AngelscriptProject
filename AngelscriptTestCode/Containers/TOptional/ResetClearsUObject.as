/**
 * @version v1
 * @summary Reset after Set leaves TOptional<UObject> unset.
 * @topic Containers
 *
 * ResetClearsUObject
 */
/**
 * @begin ResetClearsUObject
 * @summary Reset after Set leaves TOptional<UObject> unset.
 * @topic Containers
 */
UCLASS()
class UTOptionalResetClearsUObjectHost : UObject
{
}

bool ResetClearsUObject()
{
	TOptional<UObject> Optional;
	Optional.Set(nullptr);
	bool bNullWasSet = Optional.IsSet();
	Optional.Reset();
	bool bNullReset = !Optional.IsSet();
	UObject First = NewObject(GetTransientPackage(), UTOptionalResetClearsUObjectHost::StaticClass(), n"ResetClears_First", true);
	if (First == nullptr)
	{
		return false;
	}

	Optional.Set(First);
	Optional.Reset();
	return bNullWasSet && bNullReset && !Optional.IsSet() && Optional.Get(nullptr) == nullptr;
}
/** @end */
