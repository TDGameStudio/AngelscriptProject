/**
 * @version v1
 * @summary Const methods on structs.
 * @topic Language
 * @topic Syntax
 *
 * struct-const
 * struct-const-method
 * struct-const-reader-method
 * const-method-on-struct
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
