/**
 * @version v1
 * @summary Get returns the fallback while unset and the stored value while set.
 * @topic Containers
 *
 * GetReturnsStoredValue
 */
/**
 * @begin GetReturnsStoredValue
 * @summary Get returns the fallback while unset and the stored value while set.
 * @topic Containers
 */
bool GetReturnsStoredValue()
{
	TOptional<int32> Empty;
	int32 Fallback = 9;
	const int32& FromEmpty = Empty.Get(Fallback);
	TOptional<int32> SetValue;
	SetValue.Set(7);
	int32 Ignored = 9;
	const int32& FromSet = SetValue.Get(Ignored);
	TOptional<FString> Text;
	FString TextFallback = "Beta";
	const FString& EmptyText = Text.Get(TextFallback);
	Text.Set("Alpha");
	const FString& SetText = Text.Get(TextFallback);
	return FromEmpty == 9 && Fallback == 9 && FromSet == 7
		&& EmptyText == "Beta" && SetText == "Alpha";
}
/** @end */
