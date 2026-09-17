/**
 * @version v1
 * @summary A typedef alias can be a function return type.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary Make returns Count 8, which assigns to int as 8.
 * @topic Baseline
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
 * @version valid-typedef-return-of-float
 * @parent root
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
 * @version valid-typedef-return-from-method
 * @parent root
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
