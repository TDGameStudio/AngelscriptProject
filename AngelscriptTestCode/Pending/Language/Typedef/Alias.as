/**
 * @version v1
 * @summary A typedef alias used as a local and a parameter.
 * @topic Language
 * @topic Typedef
 */
/**
 * @version root
 * @summary typedef int Count can be passed and returned as int.
 * @topic Baseline
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
 * @version valid-typedef-of-float
 * @parent root
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
 * @version valid-typedef-of-bool
 * @parent root
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
 * @version valid-alias-round-trip-with-int
 * @parent root
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
