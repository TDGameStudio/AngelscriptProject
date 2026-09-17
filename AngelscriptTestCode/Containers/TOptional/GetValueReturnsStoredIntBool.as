/**
 * @version v1
 * @summary Mutable GetValue writes through to the stored bool.
 * @topic Containers
 *
 * GetValueReturnsStoredIntBool
 */
/**
 * @begin GetValueReturnsStoredIntBool
 * @summary Mutable GetValue writes through to the stored bool.
 * @topic Containers
 */
bool GetValueReturnsStoredIntBool()
{
	TOptional<bool> Optional;
	Optional.Set(true);
	bool& Mutable = Optional.GetValue();
	bool bMutableIsTrue = Mutable == true;
	Mutable = false;
	const bool& ConstValue = Optional.GetValue();
	return bMutableIsTrue && ConstValue == false && Optional.IsSet();
}
/** @end */
