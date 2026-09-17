/**
 * @version v1
 * @summary Mutable GetValue writes through to the stored value.
 * @topic Containers
 *
 * GetValueReturnsStoredInt
 */
/**
 * @begin GetValueReturnsStoredInt
 * @summary Mutable GetValue writes through to the stored value.
 * @topic Containers
 */
bool GetValueReturnsStoredInt()
{
	TOptional<int32> Optional;
	Optional.Set(7);
	int32& Mutable = Optional.GetValue();
	bool bMutableIsSeven = Mutable == 7;
	Mutable = 11;
	const int32& ConstValue = Optional.GetValue();
	TOptional<FString> Text;
	Text.Set("Alpha");
	const FString& TextValue = Text.GetValue();
	return bMutableIsSeven && ConstValue == 11 && TextValue == "Alpha";
}
/** @end */
