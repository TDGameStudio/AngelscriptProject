/**
 * @version v1
 * @summary Null assigned to values that cannot be handles.
 * @topic Language
 * @topic Casting
 *
 * invalid-null-to-value
 * invalid-nullptr-arithmetic
 * invalid-nullptr-to-bool
 * invalid-nullptr-to-float
 * invalid-nullptr-to-int
 * invalid-nullptr-to-struct
 */
/**
 * @begin invalid-null-to-value
 * @summary A value type cannot be assigned null.
 * @topic Negative
 */
void Test()
{
	int X = null;
}
/** @end */
/**
 * @begin invalid-nullptr-arithmetic
 * @summary Compile-rejection form retained from legacy nullptr arithmetic.
 * @topic Negative
 */
void Test()
{
	int X = nullptr + 1;
}
/** @end */
/**
 * @begin invalid-nullptr-to-bool
 * @summary Compile-rejection form retained from legacy nullptr to bool.
 * @topic Negative
 */
void Test()
{
	bool B = nullptr;
}
/** @end */
/**
 * @begin invalid-nullptr-to-float
 * @summary Compile-rejection form retained from legacy nullptr to float.
 * @topic Negative
 */
void Test()
{
	float X = nullptr;
}
/** @end */
/**
 * @begin invalid-nullptr-to-int
 * @summary Compile-rejection form retained from legacy nullptr to int.
 * @topic Negative
 */
void Test()
{
	int X = nullptr;
}
/** @end */
/**
 * @begin invalid-nullptr-to-struct
 * @summary A script struct value cannot be assigned null.
 * @topic Negative
 */
struct FBox
{
	int X;
}

void Test()
{
	FBox Value = null;
}
/** @end */
