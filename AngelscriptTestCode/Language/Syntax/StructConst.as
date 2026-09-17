/**
 * @version v1
 * @summary Const methods on structs.
 * @topic Language
 * @topic Syntax
 *
 * struct-const                  // A const reader method that does not mutate members.
 * struct-const-method           // Positive language form retained from legacy struct const method.
 * struct-const-reader-method    // Positive language form retained from legacy struct const reader method.
 * const-method-on-struct        // A const method that only reads members.
 * const-struct-local            // A const struct local is constructed and only read.
 * const-method-returns-field    // A const method returns one member.
 */
/**
 * @begin struct-const
 * @summary A const reader method that does not mutate members.
 */
struct FSize
{
	int Width;
	int Height;

	int Area() const
	{
		return Width * Height;
	}
}

int ReadArea()
{
	FSize Value;
	Value.Width = 2;
	Value.Height = 3;
	return Value.Area();
}
/** @end */
/**
 * @begin struct-const-method
 * @summary Positive language form retained from legacy struct const method.
 * @topic Syntax
 */
struct FStructFuncConst
	{
		int X = 0;

		int Get() const
		{
			return X;
		}
	}
/** @end */
/**
 * @begin struct-const-reader-method
 * @summary Positive language form retained from legacy struct const reader method.
 * @topic Syntax
 */
struct FStructMethods
{
	int X = 0;

	int GetX() const
	{
		return X;
	}
}
/** @end */
/**
 * @begin const-method-on-struct
 * @summary A const method that only reads members.
 * @topic Syntax
 */
struct FPoint
{
	int X;
	int Y;

	int Sum() const
	{
		return X + Y;
	}
}
/** @end */
/**
 * @begin const-struct-local
 * @summary A const struct local is constructed and only read.
 * @topic Syntax
 */
struct FSize
{
	int Width = 0;
}

int UseConstLocal()
{
	const FSize Value;
	return Value.Width;
}
/** @end */
/**
 * @begin const-method-returns-field
 * @summary A const method returns one member.
 * @topic Syntax
 */
struct FBox
{
	int Width = 2;

	int ReadWidth() const
	{
		return Width;
	}
}
/** @end */
