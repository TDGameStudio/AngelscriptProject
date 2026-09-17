/**
 * @version v1
 * @summary Explicit numeric cast forms without observation wrappers.
 * @topic Language
 * @topic Casting
 *
 * explicit-float-to-int
 * explicit-int-to-float
 * explicit-int-to-uint8
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
