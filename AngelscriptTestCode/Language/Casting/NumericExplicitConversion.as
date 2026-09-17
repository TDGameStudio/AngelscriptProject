/**
 * @version v1
 * @summary Explicit numeric cast forms without observation wrappers.
 * @topic Language
 * @topic Casting
 *
 * explicit-float-to-int      // Authored language form for explicit float to int.
 * explicit-int-to-float      // Authored language form for explicit int to float.
 * explicit-int-to-uint8      // Authored language form for explicit int to uint8.
 * explicit-float-to-uint8    // Authored language form for explicit float to uint8.
 * explicit-int64-to-int      // Authored language form for explicit int64 to int.
 * explicit-bool-to-int       // Authored language form for explicit bool to int.
 */
/**
 * @begin explicit-float-to-int
 * @summary Authored language form for explicit float to int.
 * @topic Casting
 */
/**
 * @function ExplicitFloatToInt
 * @summary Authored language form for explicit float to int.
 * @covers int()
 * @inputs none
 * @return 3 from 3.9f
 */
int ExplicitFloatToInt()
{
	return int(3.9f);
}
/** @end */
/**
 * @begin explicit-int-to-float
 * @summary Authored language form for explicit int to float.
 * @topic Casting
 */
/**
 * @function ExplicitIntToFloat
 * @summary Authored language form for explicit int to float.
 * @covers float()
 * @inputs none
 * @return 3 as float
 */
float ExplicitIntToFloat()
{
	return float(3);
}
/** @end */
/**
 * @begin explicit-int-to-uint8
 * @summary Authored language form for explicit int to uint8.
 * @topic Casting
 */
/**
 * @function ExplicitIntToUint8
 * @summary Authored language form for explicit int to uint8.
 * @covers uint8()
 * @inputs none
 * @return 200 as uint8
 */
uint8 ExplicitIntToUint8()
{
	return uint8(200);
}
/** @end */
/**
 * @begin explicit-float-to-uint8
 * @summary Authored language form for explicit float to uint8.
 * @topic Casting
 */
uint8 ExplicitFloatToUint8()
{
	return uint8(3.9f);
}
/** @end */
/**
 * @begin explicit-int64-to-int
 * @summary Authored language form for explicit int64 to int.
 * @topic Casting
 */
int ExplicitInt64ToInt()
{
	int64 Wide = 7;
	return int(Wide);
}
/** @end */
/**
 * @begin explicit-bool-to-int
 * @summary Authored language form for explicit bool to int.
 * @topic Casting
 */
int ExplicitBoolToInt()
{
	return int(true);
}
/** @end */
