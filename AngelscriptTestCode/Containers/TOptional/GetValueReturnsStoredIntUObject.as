/**
 * @version v1
 * @summary Mutable GetValue writes through to the stored UObject handle.
 * @topic Containers
 *
 * GetValueReturnsStoredIntUObject
 */
/**
 * @begin GetValueReturnsStoredIntUObject
 * @summary Mutable GetValue writes through to the stored UObject handle.
 * @topic Containers
 */
UCLASS()
class UTOptionalGetValueReturnsStoredIntUObjectHost : UObject
{
}

bool GetValueReturnsStoredIntUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTOptionalGetValueReturnsStoredIntUObjectHost::StaticClass(), n"GetValueReturnsStoredInt_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTOptionalGetValueReturnsStoredIntUObjectHost::StaticClass(), n"GetValueReturnsStoredInt_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	TOptional<UObject> Optional;
	Optional.Set(First);
	UObject& Mutable = Optional.GetValue();
	bool bMutableIsFirst = Mutable == First;
	Mutable = Second;
	const UObject& ConstValue = Optional.GetValue();
	return bMutableIsFirst && ConstValue == Second && Optional.IsSet();
}
/** @end */
