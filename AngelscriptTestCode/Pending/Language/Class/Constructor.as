/**
 * @version v1
 * @summary Class constructors that initialize instance fields.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary A class with a default constructor and a two-argument constructor.
 * @topic Baseline
 */
class APoint
{
	int X;
	int Y;

	APoint()
	{
		X = 0;
		Y = 0;
	}

	APoint(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

int Constructed()
{
	APoint Origin;
	APoint Offset(2, 3);
	return Origin.X + Offset.Y;
}
/** @end */
/**
 * @version invalid-constructor-wrong-arity
 * @parent root
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
 * @version invalid-constructor-unknown-arg-type
 * @parent root
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
 * @version valid-default-construct
 * @parent root
 * @summary A default constructor runs when a local is declared without arguments.
 * @topic Class
 */
class AOrigin
{
	int X;
	int Y;

	AOrigin()
	{
		X = 1;
		Y = 2;
	}
}

int UseDefault()
{
	AOrigin Value;
	return Value.X + Value.Y;
}
/** @end */
/**
 * @version invalid-constructor-return-type
 * @parent root
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
