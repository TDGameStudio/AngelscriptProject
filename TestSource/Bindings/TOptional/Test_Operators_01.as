// Purpose: Observe TOptional empty, value, and copy construction plus
// equality of set state and contained values. Each function returns the
// exact comparison for the C++ runner.
// AS-facing API: TOptional<T> Optional();
// TOptional<T> Optional(const T&in if_handle_then_const Other);
// TOptional<T> Optional(const TOptional<T>& Other);
// bool bEqual = Left == Right;
// Inputs: Unset default, Optional(7), copy of that optional, Optional(9),
// empty vs set, and FName n"Alpha".
// Expected observations: Default is unset. Value construction IsSet true and
// GetValue 7. Copy construction equals the source. Unset==unset true;
// 7==7 true; 7==9 false; unset==set false.
// Boundary/ownership: Constructors copy the value. Equality is value-
// returning and compares set state first.

namespace TS_TOptional_Operators_01
{
	bool Observe_Optional_Nominal()
	{
		TOptional<int32> Empty = TOptional<int32>();
		TOptional<int32> FromValue(7);
		TOptional<int32> Copied(FromValue);
		TOptional<FName> Named(n"Alpha");
		return !Empty.IsSet() && FromValue.IsSet() && FromValue.GetValue() == 7 && Copied.IsSet() && Copied.GetValue() == 7 && Copied == FromValue && Named.IsSet() && Named.GetValue() == n"Alpha";
	}

	bool Observe_Equality_Nominal()
	{
		TOptional<int32> UnsetLeft;
		TOptional<int32> UnsetRight;
		TOptional<int32> Seven(7);
		TOptional<int32> SevenOther(7);
		TOptional<int32> Nine(9);
		return UnsetLeft == UnsetRight && Seven == SevenOther && !(Seven == Nine) && !(UnsetLeft == Seven);
	}
}
