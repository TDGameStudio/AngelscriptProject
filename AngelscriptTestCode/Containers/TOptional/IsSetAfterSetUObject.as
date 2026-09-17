/**
 * @version v1
 * @summary IsSet is false when unset and true after Set on TOptional<UObject>.
 * @topic Containers
 *
 * IsSetAfterSetUObject
 */
/**
 * @begin IsSetAfterSetUObject
 * @summary IsSet is false when unset and true after Set on TOptional<UObject>.
 * @topic Containers
 */
UCLASS()
class UTOptionalIsSetAfterSetUObjectHost : UObject
{
}

bool IsSetAfterSetUObject()
{
	TOptional<UObject> Empty;
	TOptional<UObject> NullHeld;
	NullHeld.Set(nullptr);
	TOptional<UObject> SetValue;
	UObject First = NewObject(GetTransientPackage(), UTOptionalIsSetAfterSetUObjectHost::StaticClass(), n"IsSetAfterSet_First", true);
	if (First == nullptr)
	{
		return false;
	}

	SetValue.Set(First);
	return !Empty.IsSet() && NullHeld.IsSet() && SetValue.IsSet();
}
/** @end */
