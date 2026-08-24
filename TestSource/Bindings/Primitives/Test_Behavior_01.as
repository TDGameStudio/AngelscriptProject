// Purpose: Observe primitive type registration, integer min/max constants,
// double/float limits, and common mathematical constants. Each function
// returns the exact comparison for the C++ runner.
// AS-facing API: <int8 | int16 | int32 | int64> Value;
// <uint8 | uint16 | uint32 | uint64> Value; bool Value;
// <float | float32 | float64 | double> Value;
// const <uint8 | uint16 | uint32 | uint64 | int8 | int16 | int32 | int64> MIN_<type>;
// const <uint8 | uint16 | uint32 | uint64 | int8 | int16 | int32 | int64> MAX_<type>;
// const float64 <MIN_dbl | MAX_dbl | NAN_dbl>;
// const <configured-float-type> <MIN_flt | MAX_flt | NAN_flt>;
// const float64 <EULERS_NUMBER | PI | HALF_PI | TWO_PI | SMALL_NUMBER | KINDA_SMALL_NUMBER | BIG_NUMBER>;
// const float64 <THRESH_VECTOR_NORMALIZED | THRESH_NORMALS_ARE_PARALLEL | THRESH_NORMALS_ARE_ORTHOGONAL>;
// Inputs: Default zero values, explicit 1 / true, and the published constants.
// Expected observations: Signed/unsigned defaults are 0. bool false/true are
// both reachable. MIN_* is less than MAX_*. PI is greater than HALF_PI.
// Boundary/ownership: Constants are immutable globals. int aliases int32;
// uint aliases uint32; float width follows the project setting.

namespace TS_Primitives_Behavior_01
{
	// Signed integer widths default to 0 and accept 1; int aliases int32.
	bool Observe_Surface001_Nominal()
	{
		int8 Signed8 = 0;
		int16 Signed16 = 0;
		int32 Signed32 = 1;
		int64 Signed64 = 1;
		int AliasedInt = 1;
		return Signed8 == 0 && Signed16 == 0 && Signed32 == AliasedInt && Signed64 == 1;
	}

	// Unsigned integer widths default to 0 and accept 1; uint aliases uint32.
	bool Observe_Surface002_Nominal()
	{
		uint8 Unsigned8 = 0;
		uint16 Unsigned16 = 0;
		uint32 Unsigned32 = 1;
		uint64 Unsigned64 = 1;
		uint AliasedUint = 1;
		return Unsigned8 == 0 && Unsigned16 == 0 && Unsigned32 == AliasedUint && Unsigned64 == 1;
	}

	// bool defaults to false and true is a distinct value.
	bool Observe_Surface003_Nominal()
	{
		bool DefaultFlag = false;
		bool TrueFlag = true;
		return !DefaultFlag && TrueFlag;
	}

	// float/float32/float64/double accept 0.0 and 1.0; float64 matches double.
	bool Observe_Surface004_Nominal()
	{
		float DefaultFloat = 0.0;
		float32 Explicit32 = 1.0;
		float64 Explicit64 = 1.0;
		double ExplicitDouble = 1.0;
		return DefaultFloat == 0.0 && Explicit32 == 1.0 && Explicit64 == ExplicitDouble;
	}

	// Signed MIN is less than MAX; unsigned MIN is 0.
	bool Observe_Surface005_Nominal()
	{
		return MIN_int8 < MAX_int8 && MIN_int16 < MAX_int16 && MIN_int32 < MAX_int32 && MIN_int64 < MAX_int64 && MIN_uint8 == 0 && MIN_uint16 == 0 && MIN_uint32 == 0 && MIN_uint64 == 0;
	}

	// Unsigned MAX is greater than MIN; signed MAX is positive.
	bool Observe_Surface006_Nominal()
	{
		return MAX_uint8 > MIN_uint8 && MAX_uint16 > MIN_uint16 && MAX_uint32 > MIN_uint32 && MAX_uint64 > MIN_uint64 && MAX_int8 > 0 && MAX_int16 > 0 && MAX_int32 > 0 && MAX_int64 > 0;
	}

	// MIN_dbl is negative, MAX_dbl is positive, NAN_dbl is not equal to itself.
	bool Observe_Surface007_Nominal()
	{
		float64 NanValue = NAN_dbl;
		return MIN_dbl < 0.0 && MAX_dbl > 0.0 && NanValue != NanValue;
	}

	// MIN_flt is negative, MAX_flt is positive, NAN_flt is not equal to itself.
	bool Observe_Surface008_Nominal()
	{
		float NanValue = NAN_flt;
		return MIN_flt < 0.0 && MAX_flt > 0.0 && NanValue != NanValue;
	}

	// Math constants are ordered: HALF_PI < PI < TWO_PI, SMALL_NUMBER < KINDA_SMALL_NUMBER.
	bool Observe_Surface009_Nominal()
	{
		return EULERS_NUMBER > 2.0 && PI > 3.0 && HALF_PI < PI && TWO_PI > PI && SMALL_NUMBER > 0.0 && KINDA_SMALL_NUMBER > SMALL_NUMBER && BIG_NUMBER > TWO_PI;
	}

	// Vector normal/parallel/orthogonal thresholds are positive.
	bool Observe_Surface010_Nominal()
	{
		return THRESH_VECTOR_NORMALIZED > 0.0 && THRESH_NORMALS_ARE_PARALLEL > 0.0 && THRESH_NORMALS_ARE_ORTHOGONAL > 0.0;
	}
}
