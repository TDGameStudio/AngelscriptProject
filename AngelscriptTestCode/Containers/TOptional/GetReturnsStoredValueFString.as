/**
 * @version v1
 * @summary Get returns the stored FString while set and the fallback while unset.
 * @topic Containers
 *
 * GetReturnsStoredValueFString
 */
/**
 * @begin GetReturnsStoredValueFString
 * @summary Get returns the stored FString while set and the fallback while unset.
 * @topic Containers
 */
bool GetReturnsStoredValueFString()
{
	TOptional<FString> Empty;
	FString Fallback = "fallback";
	const FString& FromEmpty = Empty.Get(Fallback);
	TOptional<FString> SetValue;
	SetValue.Set("alpha");
	const FString& FromSet = SetValue.Get(Fallback);
	return FromEmpty == "fallback" && Fallback == "fallback" && FromSet == "alpha";
}
/** @end */
