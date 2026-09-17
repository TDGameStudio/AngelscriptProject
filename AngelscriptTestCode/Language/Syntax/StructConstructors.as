/**
 * @version v1
 * @summary Struct constructors and constructed locals.
 * @topic Language
 * @topic Syntax
 *
 * struct-constructors                   // A struct with a default constructor and a two-argument constructor.
 * default-constructor-only              // A struct with only a default constructor.
 * constructor-overload-set              // Default and one-argument constructors on one struct.
 * constructor-with-two-args             // A struct constructor that takes two integer arguments.
 * constructor-initializes-two-fields    // A constructor body assigns both members.
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
/**
 * @begin constructor-with-two-args
 * @summary A struct constructor that takes two integer arguments.
 * @topic Syntax
 */
struct FOffset
{
	int X;
	int Y;

	FOffset(int InX, int InY)
	{
		X = InX;
		Y = InY;
	}
}

int UseTwoArgs()
{
	FOffset Value(2, 3);
	return Value.X + Value.Y;
}
/** @end */
/**
 * @begin constructor-initializes-two-fields
 * @summary A constructor body assigns both members.
 * @topic Syntax
 */
struct FPair
{
	int Left;
	int Right;

	FPair()
	{
		Left = 1;
		Right = 2;
	}
}

int UseInitialized()
{
	FPair Value;
	return Value.Left + Value.Right;
}
/** @end */
