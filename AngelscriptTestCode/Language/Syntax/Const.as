/**
 * @version v1
 * @summary Const locals and a const method that only reads.
 * @topic Language
 * @topic Syntax
 *
 * const                     // A const local and a const method that only reads.
 * const-method-on-struct    // Positive language form retained from legacy const method on struct.
 * const-int-local           // A const int local cannot be rebound.
 * const-float-local         // A const float local cannot be rebound.
 * const-string-local        // A const string local cannot be rebound.
 */
/**
 * @begin const
 * @summary A const local and a const method that only reads.
 */
struct FHolder
{
	int Value;

	int Read() const
	{
		return Value;
	}
}

int ConstLocal()
{
	const int Limit = 3;
	FHolder Holder;
	Holder.Value = Limit;
	return Holder.Read();
}
/** @end */
/**
 * @begin const-method-on-struct
 * @summary Positive language form retained from legacy const method on struct.
 * @topic Syntax
 */
struct FStructConst
	{
		int X = 0;

		int GetX() const
		{
			return X;
		}
	}
/** @end */
/**
 * @begin const-int-local
 * @summary A const int local cannot be rebound.
 * @topic Syntax
 */
int ReadInt()
{
	const int Limit = 3;
	return Limit;
}
/** @end */
/**
 * @begin const-float-local
 * @summary A const float local cannot be rebound.
 * @topic Syntax
 */
float ReadFloat()
{
	const float Scale = 1.5f;
	return Scale;
}
/** @end */
/**
 * @begin const-string-local
 * @summary A const string local cannot be rebound.
 * @topic Syntax
 */
string Read()
{
	const string Text = "fixed";
	return Text;
}
/** @end */
