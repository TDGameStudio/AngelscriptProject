/**
 * @version v1
 * @summary Implicit numeric widening and narrowing conversion forms.
 * @topic Language
 * @topic Casting
 *
 * implicit-int-to-float
 * implicit-float-to-int
 * implicit-int-to-int64
 * implicit-int64-to-int
 * implicit-uint8-to-int
 * implicit-float-to-uint8
 * implicit-literal-to-float
 * implicit-bool-to-int
 * numeric-enum-conversions
 */
/**
 * @begin implicit-int-to-float
 * @summary Authored language form for implicit int to float.
 * @topic Casting
 */
/**
 * @function ImplicitIntToFloat
 * @summary Authored language form for implicit int to float.
 * @covers implicit widening
 * @inputs none
 * @return 3 as float
 */
float ImplicitIntToFloat()
{
	int Value = 3;
	float Wide = Value;
	return Wide;
}
/** @end */
/**
 * @begin implicit-float-to-int
 * @summary Authored language form for implicit float to int.
 * @topic Casting
 */
/**
 * @function ImplicitFloatToInt
 * @summary Authored language form for implicit float to int.
 * @covers implicit narrowing
 * @inputs none
 * @return 3 from 3.9f
 */
int ImplicitFloatToInt()
{
	float Value = 3.9f;
	int Narrow = Value;
	return Narrow;
}
/** @end */
/**
 * @begin implicit-int-to-int64
 * @summary Authored language form for implicit int to int64.
 * @topic Casting
 */
/**
 * @function ImplicitIntToInt64
 * @summary Authored language form for implicit int to int64.
 * @covers implicit widening
 * @inputs none
 * @return 7 as int64
 */
int64 ImplicitIntToInt64()
{
	int Value = 7;
	int64 Wide = Value;
	return Wide;
}
/** @end */
/**
 * @begin implicit-int64-to-int
 * @summary Authored language form for implicit int64 to int.
 * @topic Casting
 */
/**
 * @function ImplicitInt64ToInt
 * @summary Authored language form for implicit int64 to int.
 * @covers implicit narrowing
 * @inputs none
 * @return 9 as int
 */
int ImplicitInt64ToInt()
{
	int64 Value = 9;
	int Narrow = Value;
	return Narrow;
}
/** @end */
/**
 * @begin implicit-uint8-to-int
 * @summary Authored language form for implicit uint8 to int.
 * @topic Casting
 */
/**
 * @function ImplicitUint8ToInt
 * @summary Authored language form for implicit uint8 to int.
 * @covers implicit widening
 * @inputs none
 * @return 5 as int
 */
int ImplicitUint8ToInt()
{
	uint8 Value = 5;
	int Wide = Value;
	return Wide;
}
/** @end */
/**
 * @begin implicit-float-to-uint8
 * @summary Authored language form for implicit float to uint8.
 * @topic Casting
 */
/**
 * @function ImplicitFloatToUint8
 * @summary Authored language form for implicit float to uint8.
 * @covers implicit narrowing
 * @inputs none
 * @return 2 from 2.2f
 */
uint8 ImplicitFloatToUint8()
{
	float Value = 2.2f;
	uint8 Narrow = Value;
	return Narrow;
}
/** @end */
/**
 * @begin implicit-literal-to-float
 * @summary Authored language form for implicit literal to float.
 * @topic Casting
 */
/**
 * @function ImplicitLiteralToFloat
 * @summary Authored language form for implicit literal to float.
 * @covers integer literal to float
 * @inputs none
 * @return 4 as float
 */
float ImplicitLiteralToFloat()
{
	float Value = 4;
	return Value;
}
/** @end */
/**
 * @begin implicit-bool-to-int
 * @summary Authored language form for implicit bool to int.
 * @topic Casting
 */
/**
 * @function ImplicitBoolToInt
 * @summary Authored language form for implicit bool to int.
 * @covers bool to int
 * @inputs none
 * @return 1 from true
 */
int ImplicitBoolToInt()
{
	bool Flag = true;
	int Value = Flag;
	return Value;
}
/** @end */
/**
 * @begin numeric-enum-conversions
 * @summary Authored language form for numeric enum conversions.
 * @topic Casting
 */
enum ELane
{
	Low = 1,
	High = 4
}

/**
 * @function EnumToInt
 * @summary Authored language form for numeric enum conversions.
 * @covers enum to int
 * @inputs none
 * @return 4 from ELane::High
 */
int EnumToInt()
{
	ELane Lane = ELane::High;
	return int(Lane);
}

/**
 * @function IntToEnum
 * @summary Integer converts to a numeric enum.
 * @covers int to enum
 * @inputs none
 * @return ELane(1)
 */
ELane IntToEnum()
{
	return ELane(1);
}
/** @end */
