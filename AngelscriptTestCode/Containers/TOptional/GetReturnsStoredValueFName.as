/**
 * @version v1
 * @summary Get returns the stored FName while set and the fallback while unset.
 * @topic Containers
 *
 * GetReturnsStoredValueFName
 */
/**
 * @begin GetReturnsStoredValueFName
 * @summary Get returns the stored FName while set and the fallback while unset.
 * @topic Containers
 */
bool GetReturnsStoredValueFName()
{
	TOptional<FName> Empty;
	FName Fallback = n"Fallback";
	const FName& FromEmpty = Empty.Get(Fallback);
	TOptional<FName> SetValue;
	SetValue.Set(n"Red");
	const FName& FromSet = SetValue.Get(Fallback);
	return FromEmpty == n"Fallback" && Fallback == n"Fallback" && FromSet == n"Red";
}
/** @end */
