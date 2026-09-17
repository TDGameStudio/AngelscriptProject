/**
 * @version v1
 * @summary Struct constructors and constructed locals.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A struct with a default constructor and a two-argument constructor.
 * @topic Baseline
 */
struct FPoint
{
	int X;
	int Y;

	FPoint()
	{
		X = 0;
		Y = 0;
	}

	FPoint(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

int Constructed()
{
	FPoint Origin;
	FPoint Offset(2, 3);
	return Origin.X + Offset.Y;
}
/** @end */
/**
 * @version invalid-constructor-wrong-arity
 * @parent root
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
 * @version valid-default-constructor-only
 * @parent root
 * @summary A struct with only a default constructor.
 * @topic Syntax
 */
struct FOrigin
{
	int X;
	int Y;

	FOrigin()
	{
		X = 0;
		Y = 0;
	}
}

int UseDefault()
{
	FOrigin Value;
	return Value.X + Value.Y;
}
/** @end */
/**
 * @version valid-constructor-overload-set
 * @parent root
 * @summary Default and one-argument constructors on one struct.
 * @topic Syntax
 */
struct FScale
{
	int Amount;

	FScale()
	{
		Amount = 1;
	}

	FScale(int InAmount)
	{
		Amount = InAmount;
	}
}

int UseBoth()
{
	FScale Defaulted;
	FScale Explicit(4);
	return Defaulted.Amount + Explicit.Amount;
}
/** @end */
/**
 * @version invalid-constructor-unknown-arg-type
 * @parent root
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
 * @version invalid-constructor-on-primitive
 * @parent root
 * @summary A primitive cannot be constructed with a user constructor call shape.
 * @topic Negative
 */
void Test()
{
	int Value(1, 2);
}
/** @end */
