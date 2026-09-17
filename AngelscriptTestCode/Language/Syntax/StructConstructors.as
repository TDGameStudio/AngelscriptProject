/**
 * @version v1
 * @summary Struct constructors and constructed locals.
 * @topic Language
 * @topic Syntax
 *
 * struct-constructors
 * default-constructor-only
 * constructor-overload-set
 */
/**
 * @begin struct-constructors
 * @summary A struct with a default constructor and a two-argument constructor.
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
 * @begin default-constructor-only
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
 * @begin constructor-overload-set
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
