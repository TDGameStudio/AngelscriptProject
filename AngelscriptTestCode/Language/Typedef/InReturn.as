/**
 * @version v1
 * @summary Typedef aliases used as function and method return types.
 * @topic Language
 * @topic Typedef
 *
 * typedef-in-return             // Make returns Count 8, which assigns to int as 8.
 * typedef-return-of-float       // A float alias can be returned from a function.
 * typedef-return-from-method    // A method may return a typedef alias.
 */
/**
 * @begin typedef-in-return
 * @summary Make returns Count 8, which assigns to int as 8.
 * @topic Typedef
 */
typedef int Count;

Count Make()
{
	return 8;
}

int UseReturn()
{
	Count Value = Make();
	return Value;
}
/** @end */
/**
 * @begin typedef-return-of-float
 * @summary A float alias can be returned from a function.
 * @topic Typedef
 */
typedef float Scale;

Scale Make()
{
	return 1.5f;
}

float UseScale()
{
	return Make();
}
/** @end */
/**
 * @begin typedef-return-from-method
 * @summary A method may return a typedef alias.
 * @topic Typedef
 */
typedef int Count;

class AHolder
{
	Count Value()
	{
		return 9;
	}
}

int UseMethod()
{
	AHolder Object;
	return Object.Value();
}
/** @end */
