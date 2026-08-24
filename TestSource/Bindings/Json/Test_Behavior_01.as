// Purpose: Observe JSON type/value/array/object/iterator declarations and
// TryGetNumber overloads.
// AS-facing API: EJsonType Value; FJsonValue Value; FJsonArray Value;
// FJsonObject Value; FJsonObjectFieldIterator Value; FJsonValue Value();
// TryGetNumber float64/float32/int32/int64.
// Inputs: Empty wrappers, a numeric JSON value obtained from an array, 0 and
// 42 as number payloads.
// Expected observations: Empty FJsonValue GetType is None. TryGetNumber
// succeeds for 42 and writes OutNumber. Failed conversion on a string value
// returns false and leaves or does not require the out value.
// Boundary/ownership: OutNumber is written only on success.

namespace TS_Json_Behavior_01
{
	// EJsonType default enumerator is None.
	bool Observe_Surface001_Nominal()
	{
		EJsonType Type = EJsonType::None;
		return Type == EJsonType::None;
	}

	// Default FJsonValue GetType is None. Empty wrapper, no fixture.
	bool Observe_Surface009_Nominal()
	{
		FJsonValue Value;
		return Value.GetType() == EJsonType::None;
	}

	// Default FJsonArray Num is 0. Empty wrapper, no fixture.
	bool Observe_Surface010_Nominal()
	{
		FJsonArray Value;
		return Value.Num() == 0;
	}

	// Default FJsonObject IsValid is true because construction allocates an empty object.
	bool Observe_Surface011_Nominal()
	{
		FJsonObject Value;
		return Value.IsValid();
	}

	// Default FJsonObjectFieldIterator CanProceed is false. No current field.
	bool Observe_Surface012_Nominal()
	{
		FJsonObjectFieldIterator Value;
		return !Value.CanProceed;
	}

	// FJsonValue() constructs an empty wrapper whose type is None.
	bool Observe_Value_Nominal()
	{
		FJsonValue DefaultValue;
		return DefaultValue.GetType() == EJsonType::None;
	}

	// TryGetNumber writes 42 across float64/float32/int32/int64 and fails on a string.
	bool Observe_TryGetNumber_Nominal()
	{
		FJsonArray Numbers;
		Numbers.AddNumber(42);
		FJsonValue Numeric = Numbers.GetValueAt(0);
		float64 AsFloat64 = 0.0;
		float32 AsFloat32 = 0.0;
		int32 AsInt32 = 0;
		int64 AsInt64 = 0;
		bool bFloat64 = Numeric.TryGetNumber(AsFloat64);
		bool bFloat32 = Numeric.TryGetNumber(AsFloat32);
		bool bInt32 = Numeric.TryGetNumber(AsInt32);
		bool bInt64 = Numeric.TryGetNumber(AsInt64);

		FJsonArray Strings;
		Strings.AddString("x");
		FJsonValue NotNumber = Strings.GetValueAt(0);
		int32 Failed = -1;
		bool bFailed = NotNumber.TryGetNumber(Failed);
		return bFloat64 &&
			AsFloat64 == 42.0 &&
			bFloat32 &&
			AsFloat32 == 42.0f &&
			bInt32 &&
			AsInt32 == 42 &&
			bInt64 &&
			AsInt64 == 42 &&
			!bFailed &&
			Failed == -1;
	}
}
