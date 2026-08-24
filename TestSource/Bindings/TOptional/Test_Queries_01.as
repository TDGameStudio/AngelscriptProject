// Purpose: Observe IsSet, GetValue aliasing, and Get with a fallback
// reference for set and unset optionals. Each function returns the exact
// comparison for the C++ runner.
// AS-facing API: bool bIsSet = Optional.IsSet() const;
// const T& Value = Optional.GetValue() const;
// T& Value = Optional.GetValue();
// const T& Value = Optional.Get(const T&in if_handle_then_const DefaultValue) const;
// Inputs: Unset optional, optional set to 7, fallback 9, and an FString
// optional "Alpha" with fallback "Beta".
// Expected observations: Unset IsSet is false. GetValue of 7 is 7; mutating
// the mutable GetValue is visible on a later read. Unset Get(9) is 9. Set
// Get(9) is 7, not the fallback.
// Boundary/ownership: GetValue throws when unset; that path is not called
// here. Get returns the fallback reference while unset, otherwise the
// contained value.

namespace TS_TOptional_Queries_01
{
	bool Observe_IsSet_Nominal()
	{
		TOptional<int32> Empty;
		TOptional<int32> SetValue;
		SetValue.Set(7);
		TOptional<UObject> NullHandle = nullptr;
		return !Empty.IsSet() && SetValue.IsSet() && NullHandle.IsSet();
	}

	bool Observe_GetValue_Nominal()
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

	bool Observe_Get_Nominal()
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
		return FromEmpty == 9 && Fallback == 9 && FromSet == 7 && EmptyText == "Beta" && SetText == "Alpha";
	}
}
