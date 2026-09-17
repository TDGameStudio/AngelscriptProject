/**
 * @version v1
 * @summary Explicit numeric cast forms without observation wrappers.
 * @topic Language
 * @topic Casting
 */
/**
 * @version root
 * @summary Explicit int/float/uint8 casts.
 * @topic Baseline
 */
int ExplicitFloatToInt()
{
	float X = 3.9f;
	return int(X);
}

float ExplicitIntToFloat()
{
	int X = 3;
	return float(X);
}

uint8 ExplicitIntToUint8()
{
	int X = 300;
	return uint8(X);
}
/** @end */
/**
 * @version invalid-explicit-unknown-type
 * @parent root
 * @summary An unknown target type cannot be used as a cast.
 * @topic Negative
 */
void Test()
{
	int X = NotAType(1);
}
/** @end */
/**
 * @version invalid-explicit-multiple-arguments
 * @parent root
 * @summary Compile-rejection form retained from legacy explicit multiple arguments.
 * @topic Negative
 */
void Test()
{
	int X = int(1, 2, 3);
}
/** @end */
/**
 * @version invalid-explicit-string-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy explicit string to int.
 * @topic Negative
 */
void Test()
{
	string S = "hello";
	int X = int(S);
}
/** @end */
/**
 * @version invalid-explicit-to-void
 * @parent root
 * @summary Compile-rejection form retained from legacy explicit to void.
 * @topic Negative
 */
void Test()
{
	int X = 5;
	void(X);
}
/** @end */
/**
 * @version valid-explicit-float-to-int
 * @parent root
 * @summary Authored language form for explicit float to int.
 * @topic Casting
 */
int ExplicitFloatToInt()
{
	return int(3.9f);
}
/** @end */
/**
 * @version valid-explicit-int-to-float
 * @parent root
 * @summary Authored language form for explicit int to float.
 * @topic Casting
 */
float ExplicitIntToFloat()
{
	return float(3);
}
/** @end */
/**
 * @version valid-explicit-int-to-uint8
 * @parent root
 * @summary Authored language form for explicit int to uint8.
 * @topic Casting
 */
uint8 ExplicitIntToUint8()
{
	return uint8(200);
}
/** @end */
