/**
 * @version v1
 * @summary Mutable GetValue writes through to the stored FString.
 * @topic Containers
 *
 * GetValueReturnsStoredIntFString
 */
/**
 * @begin GetValueReturnsStoredIntFString
 * @summary Mutable GetValue writes through to the stored FString.
 * @topic Containers
 */
bool GetValueReturnsStoredIntFString()
{
	TOptional<FString> Optional;
	Optional.Set("alpha");
	FString& Mutable = Optional.GetValue();
	bool bMutableIsAlpha = Mutable == "alpha";
	Mutable = "beta";
	const FString& ConstValue = Optional.GetValue();
	return bMutableIsAlpha && ConstValue == "beta";
}
/** @end */
