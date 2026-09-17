/**
 * @version v1
 * @summary Get returns the stored UObject while set and the fallback while unset.
 * @topic Containers
 *
 * GetReturnsStoredValueUObject
 */
/**
 * @begin GetReturnsStoredValueUObject
 * @summary Get returns the stored UObject while set and the fallback while unset.
 * @topic Containers
 */
UCLASS()
class UTOptionalGetReturnsStoredValueUObjectHost : UObject
{
}

bool GetReturnsStoredValueUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTOptionalGetReturnsStoredValueUObjectHost::StaticClass(), n"GetReturnsStoredValue_First", true);
	UObject Fallback = NewObject(GetTransientPackage(), UTOptionalGetReturnsStoredValueUObjectHost::StaticClass(), n"GetReturnsStoredValue_Fallback", true);
	if (First == nullptr || Fallback == nullptr || First == Fallback)
	{
		return false;
	}

	TOptional<UObject> Empty;
	const UObject& FromEmpty = Empty.Get(Fallback);
	TOptional<UObject> SetValue;
	SetValue.Set(First);
	const UObject& FromSet = SetValue.Get(Fallback);
	return FromEmpty == Fallback && FromSet == First;
}
/** @end */
