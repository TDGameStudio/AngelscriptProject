/**
 * @version v1
 * @summary Const methods on structs.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A const reader method that does not mutate members.
 * @topic Baseline
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
 * @version invalid-mutate-in-const-method
 * @parent root
 * @summary A const method cannot assign a member.
 * @topic Negative
 */
struct FSize
{
	int Width;

	void Grow() const
	{
		Width += 1;
	}
}
/** @end */
/**
 * @version valid-struct-const-method
 * @parent root
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
 * @version valid-struct-const-reader-method
 * @parent root
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
 * @version invalid-mutate-member-in-const-method
 * @parent root
 * @summary Compile-rejection form retained from legacy mutate member in const method.
 * @topic Negative
 */
struct FStructConstModify
{
	int X = 0;

	void Bad() const
	{
		X = 5;
	}
}
/** @end */
/**
 * @version valid-const-method-on-struct
 * @parent root
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
