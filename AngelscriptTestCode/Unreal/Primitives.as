/**
 * @version v1
 * @summary Primitives host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Primitives
 *
 * signed-integer-widths-0
 * unsigned-integer-widths-0
 * bool-defaults-false-true
 * float-float32-float64-double
 * signed-min-less-than
 * unsigned-max-greater-than
 * min-dbl-negative-max
 * min-flt-negative-max
 * math-constants-are-ordered
 * vector-normal-parallel-orthogonal
 * float32-math-constants-keep
 * float32-normal-thresholds-are
 * assignment
 */
/**
 * @begin signed-integer-widths-0
 * @summary Signed integer widths default to 0 and accept 1.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Signed integer widths default to 0 and accept 1.
 * @covers Primitives.signed-integer-widths-0
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	int8 Signed8 = 0;
	int16 Signed16 = 0;
	int32 Signed32 = 1;
	int64 Signed64 = 1;
	int AliasedInt = 1;
	return Signed8 == 0 && Signed16 == 0 && Signed32 == AliasedInt && Signed64 == 1;
}
/** @end */
/**
 * @begin unsigned-integer-widths-0
 * @summary Unsigned integer widths default to 0 and accept 1.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Unsigned integer widths default to 0 and accept 1.
 * @covers Primitives.unsigned-integer-widths-0
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	uint8 Unsigned8 = 0;
	uint16 Unsigned16 = 0;
	uint32 Unsigned32 = 1;
	uint64 Unsigned64 = 1;
	uint AliasedUint = 1;
	return Unsigned8 == 0 && Unsigned16 == 0 && Unsigned32 == AliasedUint && Unsigned64 == 1;
}
/** @end */
/**
 * @begin bool-defaults-false-true
 * @summary bool defaults to false and true is a distinct value.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary bool defaults to false and true is a distinct value.
 * @covers Primitives.bool-defaults-false-true
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	bool DefaultFlag = false;
	bool TrueFlag = true;
	return !DefaultFlag && TrueFlag;
}
/** @end */
/**
 * @begin float-float32-float64-double
 * @summary float/float32/float64/double accept 0.0 and 1.0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary float/float32/float64/double accept 0.0 and 1.0.
 * @covers Primitives.float-float32-float64-double
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	float DefaultFloat = 0.0;
	float32 Explicit32 = 1.0;
	float64 Explicit64 = 1.0;
	double ExplicitDouble = 1.0;
	return DefaultFloat == 0.0 && Explicit32 == 1.0 && Explicit64 == ExplicitDouble;
}
/** @end */
/**
 * @begin signed-min-less-than
 * @summary Signed MIN is less than MAX.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary Signed MIN is less than MAX.
 * @covers Primitives.signed-min-less-than
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
{
	return MIN_int8 < MAX_int8 && MIN_int16 < MAX_int16 && MIN_int32 < MAX_int32 && MIN_int64 < MAX_int64 && MIN_uint8 == 0 && MIN_uint16 == 0 && MIN_uint32 == 0 && MIN_uint64 == 0;
}
/** @end */
/**
 * @begin unsigned-max-greater-than
 * @summary Unsigned MAX is greater than MIN.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary Unsigned MAX is greater than MIN.
 * @covers Primitives.unsigned-max-greater-than
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface006Nominal()
{
	return MAX_uint8 > MIN_uint8 && MAX_uint16 > MIN_uint16 && MAX_uint32 > MIN_uint32 && MAX_uint64 > MIN_uint64 && MAX_int8 > 0 && MAX_int16 > 0 && MAX_int32 > 0 && MAX_int64 > 0;
}
/** @end */
/**
 * @begin min-dbl-negative-max
 * @summary MIN_dbl is negative, MAX_dbl is positive, NAN_dbl is not equal to itself.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary MIN_dbl is negative, MAX_dbl is positive, NAN_dbl is not equal to itself.
 * @covers Primitives.min-dbl-negative-max
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface007Nominal()
{
	float64 NanValue = NAN_dbl;
	return MIN_dbl < 0.0 && MAX_dbl > 0.0 && NanValue != NanValue;
}
/** @end */
/**
 * @begin min-flt-negative-max
 * @summary MIN_flt is negative, MAX_flt is positive, NAN_flt is not equal to itself.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary MIN_flt is negative, MAX_flt is positive, NAN_flt is not equal to itself.
 * @covers Primitives.min-flt-negative-max
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface008Nominal()
{
	float NanValue = NAN_flt;
	return MIN_flt < 0.0 && MAX_flt > 0.0 && NanValue != NanValue;
}
/** @end */
/**
 * @begin math-constants-are-ordered
 * @summary Math constants are ordered: HALF_PI < PI < TWO_PI, SMALL_NUMBER < KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary Math constants are ordered: HALF_PI < PI < TWO_PI, SMALL_NUMBER < KINDA_SMALL_NUMBER.
 * @covers Primitives.math-constants-are-ordered
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface009Nominal()
{
	return EULERS_NUMBER > 2.0 && PI > 3.0 && HALF_PI < PI && TWO_PI > PI && SMALL_NUMBER > 0.0 && KINDA_SMALL_NUMBER > SMALL_NUMBER && BIG_NUMBER > TWO_PI;
}
/** @end */
/**
 * @begin vector-normal-parallel-orthogonal
 * @summary Vector normal/parallel/orthogonal thresholds are positive.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary Vector normal/parallel/orthogonal thresholds are positive.
 * @covers Primitives.vector-normal-parallel-orthogonal
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface010Nominal()
{
	return THRESH_VECTOR_NORMALIZED > 0.0 && THRESH_NORMALS_ARE_PARALLEL > 0.0 && THRESH_NORMALS_ARE_ORTHOGONAL > 0.0;
}
/** @end */
/**
 * @begin float32-math-constants-keep
 * @summary Float32 math constants keep the same ordering as the double-width family.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Float32 math constants keep the same ordering as the double-width family.
 * @covers Primitives.float32-math-constants-keep
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface011Nominal()
{
	return __EULERS_NUMBER_flt > 2.0 && __PI_flt > 3.0 && __HALF_PI_flt < __PI_flt && __TWO_PI_flt > __PI_flt && __SMALL_NUMBER_flt > 0.0 && __KINDA_SMALL_NUMBER_flt > __SMALL_NUMBER_flt && __BIG_NUMBER_flt > __TWO_PI_flt;
}
/** @end */
/**
 * @begin float32-normal-thresholds-are
 * @summary Float32 normal thresholds are positive.
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary Float32 normal thresholds are positive.
 * @covers Primitives.float32-normal-thresholds-are
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface012Nominal()
{
	return __THRESH_VECTOR_NORMALIZED_flt > 0.0 && __THRESH_NORMALS_ARE_PARALLEL_flt > 0.0 && __THRESH_NORMALS_ARE_ORTHOGONAL_flt > 0.0;
}
/** @end */
/**
 * @begin assignment
 * @summary primitive values remain independent of the formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary primitive values remain independent of the formatted text.
 * @covers Primitives.assignment
 * @inputs Primitives values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	int8 Signed8 = 7;
	int16 Signed16 = 7;
	int32 Signed32 = 7;
	int64 Signed64 = 7;
	uint8 Unsigned8 = 7;
	uint16 Unsigned16 = 7;
	uint32 Unsigned32 = 7;
	uint64 Unsigned64 = 7;
	float32 Float32Value = 7.5;
	float64 Float64Value = 7.5;
	bool Flag = true;

	FString TextInt8 = f"{Signed8}";
	FString TextInt16 = f"{Signed16}";
	FString TextInt32 = f"{Signed32}";
	FString TextInt64 = f"{Signed64}";
	FString TextUInt8 = f"{Unsigned8}";
	FString TextUInt16 = f"{Unsigned16}";
	FString TextUInt32 = f"{Unsigned32}";
	FString TextUInt64 = f"{Unsigned64}";
	FString TextFloat32 = f"{Float32Value}";
	FString TextFloat64 = f"{Float64Value}";
	FString TextBool = f"{Flag}";

	int8 Zero8 = 0;
	bool FalseFlag = false;
	FString TextZero = f"{Zero8}";
	FString TextFalse = f"{FalseFlag}";
	FString Copied = TextInt32;
	return TextInt8 == "7" && TextInt16 == "7" && TextInt32 == "7" && TextInt64 == "7" && TextUInt8 == "7" && TextUInt16 == "7" && TextUInt32 == "7" && TextUInt64 == "7" && TextFloat32.Contains("7") && TextFloat64.Contains("7") && TextBool.Len() > 0 && TextZero == "0" && TextFalse.Len() > 0 && Copied == TextInt32;
}
/** @end */
