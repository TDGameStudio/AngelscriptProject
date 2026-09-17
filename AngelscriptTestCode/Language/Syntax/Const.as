/**
 * @version v1
 * @summary Const locals, const parameters, and const methods.
 * @topic Language
 * @topic Syntax
 *
 * const
 * const-method-on-struct
 * const-values-methods-and-references
 * const-string-local
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
 * @begin const-values-methods-and-references
 * @summary Positive language form retained from legacy const values methods and references.
 * @topic Syntax
 */
const int GlobalLimit = 12;

namespace SyntaxTest
{
	int LocalConstValue()
	{
		const int LocalLimit = 5;
		return LocalLimit + GlobalLimit;
	}

	int AddReadonly(const int&in Amount)
	{
		return 30 + Amount;
	}

	int ConstInRefRead()
	{
		const int Bonus = 34;
		return AddReadonly(Bonus);
	}

	int SumConstArray(const array<int>&in Values)
	{
		int Sum = 0;
		for (const int& Value : Values)
		{
			Sum += Value;
		}
		return Sum;
	}

	int ConstContainerRead()
	{
		array<int> Values;
		Values.insertLast(3);
		Values.insertLast(4);
		Values.insertLast(5);
		return SumConstArray(Values);
	}

	
	
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
