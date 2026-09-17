/**
 * @version v1
 * @summary Compile-fail cases for StructConstructors.
 * @topic Language
 * @topic Syntax
 *
 * invalid-constructor-wrong-arity
 * invalid-constructor-unknown-arg-type
 * invalid-constructor-on-primitive
 */
/**
 * @begin invalid-constructor-wrong-arity
 * @summary A constructor call must match a declared arity.
 * @topic Negative
 */
struct FPoint
{
	int X;
	FPoint(int InX)
	{
		X = InX;
	}
}

void Test()
{
	FPoint Value(1, 2);
}
/** @end */
/**
 * @begin invalid-constructor-unknown-arg-type
 * @summary Constructor parameter type must exist.
 * @topic Negative
 */
struct FPoint
{
	int X;

	FPoint(MissingType Value)
	{
		X = 0;
	}
}
/** @end */
/**
 * @begin invalid-constructor-on-primitive
 * @summary A primitive cannot be constructed with a user constructor call shape.
 * @topic Negative
 */
void Test()
{
	int Value(1, 2);
}
/** @end */
