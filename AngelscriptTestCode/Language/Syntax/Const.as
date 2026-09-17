/**
 * @version v1
 * @summary Const locals, const parameters, and const methods.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A const local and a const method that only reads.
 * @topic Baseline
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
 * @version invalid-assign-const-local
 * @parent root
 * @summary A const local cannot be reassigned.
 * @topic Negative
 */
void Test()
{
	const int Limit = 3;
	Limit = 4;
}
/** @end */
/**
 * @version invalid-const-without-initializer
 * @parent root
 * @summary A const local requires an initializer.
 * @topic Negative
 */
void Test()
{
	const int Limit;
}
/** @end */
/**
 * @version invalid-const-local-mutation
 * @parent root
 * @summary Compile-rejection form retained from legacy const local mutation.
 * @topic Negative
 */
void Test()
{
	const int Value = 1;
	Value = 2;
}
/** @end */
/**
 * @version invalid-const-method-member-mutation
 * @parent root
 * @summary Compile-rejection form retained from legacy const method member mutation.
 * @topic Negative
 */
class ConstMutationProbe
{
	int Value = 0;

void Mutate() const
	{
		Value = 2;
	}
}
/** @end */
/**
 * @version invalid-const-value-parameter-mutation
 * @parent root
 * @summary Compile-rejection form retained from legacy const value parameter mutation.
 * @topic Negative
 */
void Test(const int Value)
{
	Value = 2;
}
/** @end */
/**
 * @version valid-const-method-on-struct
 * @parent root
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
 * @version valid-const-values-methods-and-references
 * @parent root
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
 * @version valid-const-string-local
 * @parent root
 * @summary A const string local cannot be rebound.
 * @topic Syntax
 */
string Read()
{
	const string Text = "fixed";
	return Text;
}
/** @end */
/**
 * @version invalid-this-outside-class
 * @parent root
 * @summary This is invalid outside a class or struct method.
 * @topic Negative
 */
void Test()
{
	int Value = this;
}
/** @end */
