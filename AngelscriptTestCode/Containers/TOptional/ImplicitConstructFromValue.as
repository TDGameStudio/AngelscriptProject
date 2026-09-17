/**
 * @version v1
 * @summary Implicit construction from a value marks the optional set.
 * @topic Containers
 *
 * ImplicitConstructFromValue
 */
/**
 * @begin ImplicitConstructFromValue
 * @summary Implicit construction from a value marks the optional set.
 * @topic Containers
 */
bool ImplicitConstructFromValue()
{
	TOptional<int32> FromValue(7);
	TOptional<FName> Named(n"Alpha");
	return FromValue.IsSet() && FromValue.GetValue() == 7
		&& Named.IsSet() && Named.GetValue() == n"Alpha";
}
/** @end */
