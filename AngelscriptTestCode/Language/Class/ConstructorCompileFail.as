/**
 * @version v1
 * @summary Constructor forms that do not compile.
 * @topic Language
 * @topic Class
 *
 * invalid-constructor-wrong-arity         // A constructor call must match a declared arity.
 * invalid-constructor-unknown-arg-type    // Constructor parameter type must exist.
 * invalid-constructor-return-type         // A constructor cannot declare a return type.
 */
/**
 * @begin invalid-constructor-wrong-arity
 * @summary A constructor call must match a declared arity.
 * @topic Negative
 */
class APoint
{
	int X;

	APoint(int InX)
	{
		X = InX;
	}
}

void Test()
{
	APoint Value(1, 2);
}
/** @end */
/**
 * @begin invalid-constructor-unknown-arg-type
 * @summary Constructor parameter type must exist.
 * @topic Negative
 */
class APoint
{
	int X;

	APoint(MissingType Value)
	{
		X = 0;
	}
}
/** @end */
/**
 * @begin invalid-constructor-return-type
 * @summary A constructor cannot declare a return type.
 * @topic Negative
 */
class APoint
{
	int X;

	int APoint()
	{
		X = 0;
		return 0;
	}
}
/** @end */
