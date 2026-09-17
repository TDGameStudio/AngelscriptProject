/**
 * @version v1
 * @summary Mutable GetValue writes through to the stored FName.
 * @topic Containers
 *
 * GetValueReturnsStoredIntFName
 */
/**
 * @begin GetValueReturnsStoredIntFName
 * @summary Mutable GetValue writes through to the stored FName.
 * @topic Containers
 */
bool GetValueReturnsStoredIntFName()
{
	TOptional<FName> Optional;
	Optional.Set(n"Red");
	FName& Mutable = Optional.GetValue();
	bool bMutableIsRed = Mutable == n"Red";
	Mutable = n"Green";
	const FName& ConstValue = Optional.GetValue();
	return bMutableIsRed && ConstValue == n"Green";
}
/** @end */
