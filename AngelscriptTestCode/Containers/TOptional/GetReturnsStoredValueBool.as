/**
 * @version v1
 * @summary Get returns stored false while set and the fallback while unset.
 * @topic Containers
 *
 * GetReturnsStoredValueBool
 */
/**
 * @begin GetReturnsStoredValueBool
 * @summary Get returns stored false while set and the fallback while unset.
 * @topic Containers
 */
bool GetReturnsStoredValueBool()
{
	TOptional<bool> Empty;
	bool Fallback = true;
	const bool& FromEmpty = Empty.Get(Fallback);
	TOptional<bool> SetValue;
	SetValue.Set(false);
	const bool& FromSet = SetValue.Get(Fallback);
	return FromEmpty == true && Fallback == true && FromSet == false;
}
/** @end */
