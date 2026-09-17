/**
 * @version v1
 * @summary Typedef aliases of primitive types used as locals and parameters.
 * @topic Language
 * @topic Typedef
 *
 * alias                        // typedef int Count can be passed and returned as int.
 * typedef-of-float             // A typedef may alias float.
 * typedef-of-bool              // A typedef may alias bool.
 * alias-round-trip-with-int    // A Count alias assigns to and from int.
 */
/**
 * @begin alias
 * @summary typedef int Count can be passed and returned as int.
 * @topic Typedef
 */
typedef int Count;

int Add(Count Left, Count Right)
{
	return Left + Right;
}

int UseAlias()
{
	Count Value = 3;
	return Add(Value, 4);
}
/** @end */
/**
 * @begin typedef-of-float
 * @summary A typedef may alias float.
 * @topic Typedef
 */
typedef float Scale;

float Apply(Scale Amount)
{
	return Amount * 2.0f;
}
/** @end */
/**
 * @begin typedef-of-bool
 * @summary A typedef may alias bool.
 * @topic Typedef
 */
typedef bool Flag;

bool UseFlag()
{
	Flag Value = true;
	return Value;
}
/** @end */
/**
 * @begin alias-round-trip-with-int
 * @summary A Count alias assigns to and from int.
 * @topic Typedef
 */
typedef int Count;

int UseRoundTrip()
{
	Count Value = 5;
	int Copy = Value;
	Count Again = Copy;
	return Again;
}
/** @end */
